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

    # 設定ファイルの読み込み
    source "$top_dir/conf/conf-sample.sh"
    if [[ -e "$top_dir/conf/conf.sh" ]]; then
        source "$top_dir/conf/conf.sh"
    fi

    # debootrapの設定ファイルの読み込み
    source "$top_dir/conf/conf_debootstrap-sample.sh"
    if [[ -e "$top_dir/conf/conf_debootstrap.sh" ]]; then
        source "$top_dir/conf/conf_debootstrap.sh"
    fi

    # apt sources listの読み込み
    if [[ -e "$top_dir/conf/conf_apt_sources_list" ]]; then
        apt_list_path="$top_dir/conf/conf_apt_sources_list"
    else
        apt_list_path="$top_dir/conf/conf_apt_sources_list-sample"
    fi
    _DEBSTRAP_APT_SOURCE=`cat "$apt_list_path"`

    export _LINUX_SRC
    export _BUSYBOX_SRC
    export _OPENSBI_SRC
    export _UBOOT_SRC

    export _KERNEL_PATH
    export _BUSYBOX_PATH
    export _OPENSBI_PATH
    export _OPENSBI_UBOOT_PATH

    export _INIT_DISK_PATH
    export _DISK_PATH

    export _QEMU_MEMORY
    export _QEMU_SMP

    export _DISK_TOTAL_SIZE
    export _DISK_ROOT_SIZE
    export _DISK_BOOT_SIZE
    export _DISK_SWAP_SIZE

    export _KERNEL_IMG_PKG
    export _KERNEL_HEADERS_PKG
    export _INITRAMFS_PKG

    export _DEBSTRAP_KEYRING
    export _DEBSTRAP_INCLUDE
    export _DEBSTRAP_SUITE
    export _DEBSTRAP_URL

    export _DEBSTRAP_APT_SOURCE
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
# $2:bootパーティションのサイズ
# $3:rootパーティションのサイズ
# $4:swapパーティションのサイズ
function set_partion(){
    disk=$1
    boot_size=$2
    root_size=$3
    swap_size=$4

    # 初期化
    sudo sgdisk --zap-all "$disk";sudo partprobe

    # 作成
    sudo sgdisk --new "1::+$boot_size" "$disk";sudo partprobe
    sudo sgdisk --new "2::+$root_size" "$disk";sudo partprobe
    if [[ "$swap_size" != 'no' ]]; then
        sudo sgdisk --new "3::+$swap_size" "$disk";sudo partprobe
    fi

    # パーティションコード指定
    sudo sgdisk --typecode 1:8300 "$disk";sudo partprobe
    sudo sgdisk --typecode 2:8300 "$disk";sudo partprobe
    if [[ "$swap_size" != 'no' ]]; then
        sudo sgdisk --typecode 3:8200 "$disk";sudo partprobe
    fi

    # 名前付け
    sudo sgdisk --change-name '1:boot' "$disk";sudo partprobe
    sudo sgdisk --change-name '2:root' "$disk";sudo partprobe
    if [[ "$swap_size" != 'no' ]]; then
        sudo sgdisk --change-name '3:swap' "$disk";sudo partprobe
    fi

}

# ディスクとパーティションラベルからデバイス名を取得する
function name_to_devname(){
    disk=$1
    name=$2
    num=`sudo gdisk -l "$disk" | grep -E '^ +[1-9][0-9]* +.* +'$name'$' | sed -r 's#^ +([1-9][0-9]*) +.* +'$name'$#\1#g' | head -n 1`
    if [[ ! $num =~ ^.+$ ]]; then
        echo 'no'
        exit
    fi
    partid_large=`sudo sgdisk "$disk" "-i=$num" | grep '^Partition unique GUID:' | sed -r 's#^Partition unique GUID: +([^ ]+)$#\1#g' | head -n 1`
    if [[ ! $partid_large =~ ^.+$ ]]; then
        echo 'no'
        exit
    fi
    partid_large=`echo "$partid_large" | tr '[:upper:]' '[:lower:]'`

    sudo findfs PARTUUID="$partid_large"
}

# フォーマットを行う
# $1:ディスクパス
function set_format(){
    disk=$1

    boot_dev=`name_to_devname "$disk" 'boot'`
    root_dev=`name_to_devname "$disk" 'root'`
    swap_dev=`name_to_devname "$disk" 'swap'`

    sudo mkfs.ext4 "$boot_dev"
    sudo mkfs.ext4 "$root_dev"
    if [[ $swap_dev != 'no' ]]; then
        sudo mkswap "$swap_dev"
    fi
}

# デバイスからUUIDを取得する
function get_uuid_by_device(){
    device=$1
    uuid_type=$2
    if [[ ! "$uuid_type" =~ ^.+$ ]]; then
        uuid_type='UUID'
    fi
    uuid=`sudo blkid "$device" \
        | grep -E '^/dev/.*:( .*)? '$uuid_type'=([^ ]+)( .*)?$' \
        | sed -r 's#^/dev/.*:( .*)? '$uuid_type'=([^ ]+)( .*)?$#\2#g' \
        | head -n 1`

    if [[ $uuid =~ ^.+$ ]]; then
        echo "$uuid"
    else
        echo '対象のデバイスがありません。'
        exit 1
    fi
}

# 指定のディレクトリ以下を全てアンマウント
function umount_all(){
    mnt_point=$1

    sudo mount | grep "on $mnt_point" \
        | sed -E 's#^.* on ('$mnt_point'[^ ]*) type .*$#\1#g' \
        | tac \
        | xargs -I mntP sudo umount 'mntP'
}
