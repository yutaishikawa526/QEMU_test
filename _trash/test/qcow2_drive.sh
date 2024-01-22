#!/bin/bash -e

# qcow2のディスクを`-drive`で指定する方法

sudo apt install -y kpartx

_EXCE_DIR=$(cd $(dirname $0) ; pwd)
_CENTOS_ISO_DIR=`(cd "$_EXCE_DIR/../../iso/iso_CentOS6.4";pwd)`
_TMP_IMG_PATH="$_EXCE_DIR/disk/tmp.img"

function remove_loopback(){
    tmp_img=$1

    losetup | grep "$tmp_img" \
    | sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
    | xargs -I loop_num sudo kpartx -d "loop_num"
    losetup | grep "$tmp_img" \
    | sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
    | xargs -I loop_num sudo losetup -d "loop_num"
}

function create_loopback(){
    tmp_img=$1

    remove_loopback "$tmp_img"

    sudo kpartx -a "$tmp_img"
    loopback=`losetup | grep "$tmp_img" | sed -r 's#/dev/(loop[0-9]+) *.*#\1#g' | head -n 1`

    echo "$loopback"
}

# isoでのCentOSの起動可能ディスクを作成
if [[ "$1" == 'initialize=yes' ]]; then
    echo 'start init'

    bash "$_CENTOS_ISO_DIR/initial_install.sh"

    exit
fi

# 追加のディスクを作成
if [[ "$1" == 'create=yes' ]]; then
    echo 'start create'

    dd if=/dev/zero of="$_TMP_IMG_PATH" bs=1G count=2

    sudo gdisk "$_TMP_IMG_PATH" << END
    `echo '';echo '';echo 'n';echo '';echo '';echo '+1G';echo '';echo 'n';echo '';echo '';echo '';echo '';echo 'w';echo 'y';`
END

    sudo partprobe

    exit
fi

# 追加のディスクをフォーマット
if [[ "$1" == 'format=yes' ]]; then
    echo 'start format'

    loopback=`create_loopback "$_TMP_IMG_PATH"`

    sudo mkfs.ext4 "/dev/mapper/$loopback"p1
    sudo mkfs.ext4 "/dev/mapper/$loopback"p2

    remove_loopback "$_TMP_IMG_PATH"

    exit
fi

# 追加のディスクをqcow2へ
if [[ "$1" == 'convert=yes' ]]; then
    echo 'start convert'

    loopback=`create_loopback "$_TMP_IMG_PATH"`

    sudo qemu-img convert -f raw -O qcow2 "/dev/mapper/$loopback"p1 "$_TMP_IMG_PATH"_qcow2_1
    sudo qemu-img convert -f raw -O qcow2 "/dev/mapper/$loopback"p2 "$_TMP_IMG_PATH"_qcow2_2

    sudo qemu-img convert -f raw -O qcow2 "/dev/$loopback" "$_TMP_IMG_PATH"_qcow2_x

    remove_loopback "$_TMP_IMG_PATH"

    exit
fi

# 実行
if [[ "$1" == 'exe=yes' ]]; then
    echo 'start exe'

    sudo qemu-system-x86_64 \
        -m 1024 -enable-kvm -cpu host \
        "$_CENTOS_ISO_DIR/disk_iso/CentOS.qcow2" \
        -drive format=qcow2,media=disk,file="$_TMP_IMG_PATH"_qcow2_1
        -drive format=qcow2,media=disk,file="$_TMP_IMG_PATH"_qcow2_2

    exit
fi

# 実行その2
if [[ "$1" == 'exe2=yes' ]]; then
    echo 'start exe2'

    # これも動いた
    # また中への書き込みが保持されていることを確認
    sudo qemu-system-x86_64 \
        -m 1024 -enable-kvm -cpu host \
        "$_CENTOS_ISO_DIR/disk_iso/CentOS.qcow2" \
        -drive format=qcow2,media=disk,file="$_TMP_IMG_PATH"_qcow2_x

    exit
fi
