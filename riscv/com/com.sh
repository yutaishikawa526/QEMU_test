#!/bin/bash -ex

# 共通の処理を定義

# 環境変数をexportする
# @param $1 トップディレクトリのフルパス(riscvディレクトリのフルパス)
function export_env(){
    top_dir=$1

    if [[ ! -d "$top_dir" ]]; then
        echo 'トップディレクトリの指定が適切でありません。1'
        exit 1
    fi
    if [[ ! "$top_dir" =~ ^.*/riscv$ ]]; then
        echo 'トップディレクトリの指定が適切でありません。2'
        exit 1
    fi

    _LINUX_SRC="$top_dir/clone/linux"
    _BUSYBOX_SRC="$top_dir/clone/busyBox"
    _OPENSBI_SRC="$top_dir/clone/opensbi"

    _KERNEL_PATH="$top_dir/disk/kernelImage"
    _BUSYBOX_PATH="$top_dir/disk/busybox"
    _OPENSBI_PATH="$top_dir/disk/opensbi"

    _INIT_DISK_PATH="$top_dir/disk/init_disk.raw"
    _DISK_PATH="$top_dir/disk/img.raw"

    _COM_DIR="$top_dir/com"

    export _LINUX_SRC
    export _BUSYBOX_SRC
    export _OPENSBI_SRC

    export _KERNEL_PATH
    export _BUSYBOX_PATH
    export _OPENSBI_PATH

    export _INIT_DISK_PATH
    export _DISK_PATH

    export _COM_DIR
}

# 関数が定義済みか確認
function check_func(){
    func_name=$1
    apt_pkg=$2

    count=`which "$func_name" | wc -l`

    if [[ $count == 0 ]]; then
        sudo apt install -y "$apt_pkg"
    fi
}

check_func 'sgdisk' 'gdisk'
check_func 'partprobe' 'parted'
check_func 'losetup' 'mount'
check_func 'kpartx' 'kpartx'
check_func 'mkfs.vfat' 'dosfstools'
check_func 'mkfs.ext4' 'e2fsprogs'
check_func 'mkswap' 'util-linux'
check_func 'findfs' 'util-linux'

# ディレクトリか
function is_dir(){
    for i in $@
    do
        if [ ! -d "$i" ]; then
            echo "$i"'はディレクトリではありません'
        fi
    done
}

# ファイルか
function is_file(){
    for i in $@
    do
        if [ ! -e "$i" ]; then
            echo "$i"'はファイルではありません'
        fi
    done
}

# ディスクイメージファイルのループバックディスクを解除する
function unset_device(){
    disk=$1

    sudo losetup | grep "$disk" \
        | sed -r 's#^(/dev/loop[0-9]+) *.*$#\1#g' \
        | xargs -I lpdk sudo kpartx -d 'lpdk'

    sudo losetup | grep "$disk" \
        | sed -r 's#^(/dev/loop[0-9]+) *.*$#\1#g' \
        | xargs -I lpdk sudo losetup -d 'lpdk'

}

# ディスクイメージファイルをループバックディスクに展開する
# ループバックディスクパスを返す
function set_device(){
    disk=$1

    unset_device "$disk"

    sudo kpartx -a "$disk"
    loopback=`sudo losetup | grep "$disk" | sed -r 's#^(/dev/loop[0-9]+) *.*$#\1#g' | head -n 1`
    is_file "$loopback"
    echo "$loopback"
}

# パーティション分けを行う
# $1:ディスクパス
# $2:efiパーティションのサイズ
# $3:bootパーティションのサイズ
# $4:rootパーティションのサイズ
# $5:swapパーティションのサイズ
function set_partion(){
    disk=$1
    efi_size=$2
    boot_size=$3
    root_size=$4
    swap_size=$5

    # 初期化
    sudo sgdisk --zap-all "$disk";sudo partprobe

    # 作成
    sudo sgdisk --new '1::+1M' "$disk";sudo partprobe
    sudo sgdisk --new "2::+$efi_size" "$disk";sudo partprobe
    sudo sgdisk --new "3::+$boot_size" "$disk";sudo partprobe
    sudo sgdisk --new "4::+$root_size" "$disk";sudo partprobe
    if [[ "$swap_size" != 'no' ]]; then
        sudo sgdisk --new "5::+$swap_size" "$disk";sudo partprobe
    fi

    # パーティションコード指定
    sudo sgdisk --typecode 1:ef02 "$disk";sudo partprobe
    sudo sgdisk --typecode 2:ef00 "$disk";sudo partprobe
    sudo sgdisk --typecode 3:8300 "$disk";sudo partprobe
    sudo sgdisk --typecode 4:8300 "$disk";sudo partprobe
    if [[ "$swap_size" != 'no' ]]; then
        sudo sgdisk --typecode 5:8200 "$disk";sudo partprobe
    fi

    # 名前付け
    sudo sgdisk --change-name '1:biosgrub' "$disk";sudo partprobe
    sudo sgdisk --change-name '2:efi' "$disk";sudo partprobe
    sudo sgdisk --change-name '3:boot' "$disk";sudo partprobe
    sudo sgdisk --change-name '4:root' "$disk";sudo partprobe
    if [[ "$swap_size" != 'no' ]]; then
        sudo sgdisk --change-name '5:swap' "$disk";sudo partprobe
    fi

}

# ディスクとパーティションラベルからpartuuidを取得する
# ない場合は'no'を返す
function name_to_partid(){
    disk=$1
    name=$2
    num=`sudo gdisk -l "$disk" | grep -E '^ +[1-9][0-9]* +.* +'$name'$' | sed -r 's#^ +([1-9][0-9]*) +.* +'$name'$#\1#g' | head -n 1`
    if ! [[ $num =~ ^.+$ ]]; then
        echo 'no'
        exit
    fi
    partid_large=`sudo sgdisk "$disk" "-i=$num" | grep '^Partition unique GUID:' | sed -r 's#^Partition unique GUID: +([^ ]+)$#\1#g' | head -n 1`
    if ! [[ $partid_large =~ ^.+$ ]]; then
        echo 'no'
        exit
    fi
    echo "$partid_large" | tr '[:upper:]' '[:lower:]'
}

# フォーマットを行う
# $1:ディスクパス
function set_format(){
    disk=$1

    efi_partid=`name_to_partid "$disk" 'efi'`
    boot_partid=`name_to_partid "$disk" 'boot'`
    root_partid=`name_to_partid "$disk" 'root'`
    swap_partid=`name_to_partid "$disk" 'swap'`

    sudo mkfs.vfat `sudo findfs PARTUUID="$efi_partid"`
    sudo mkfs.ext4 `sudo findfs PARTUUID="$boot_partid"`
    sudo mkfs.ext4 `sudo findfs PARTUUID="$root_partid"`
    if [[ $swap_partid != 'no' ]]; then
        sudo mkswap `sudo findfs PARTUUID="$swap_partid"`
    fi
}

# デバイスからUUIDを取得する
function get_uuid_by_device(){
    device=$1
    uuid_type=$2
    if ! [[ "$uuid_type" =~ ^.+$ ]]; then
        uuid_type='UUID'
    fi
    uuid=`sudo blkid "$device" \
        | grep -E '^/dev/.*:( .*)? '$uuid_type'=([^ ]+)( .*)?$' \
        | sed -r 's#.*^/dev/.*:( .*)? '$uuid_type'=([^ ]+)( .*)?$#\2#g' \
        | head -n 1`

    if [[ $uuid =~ ^.+$ ]]; then
        echo "$uuid"
    else
        echo '対象のデバイスがありません。'
        exit 1
    fi
}
