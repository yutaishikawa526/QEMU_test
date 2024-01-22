#!/bin/bash -e

# qcow2のディスクを`-drive`で指定する方法

_EXCE_DIR=$(cd $(dirname $0) ; pwd)
_UBUNTU_ISO_DIR=`(cd "$_EXCE_DIR/../../iso/iso_Ubuntu20";pwd)`
_TMP_IMG_PATH="$_UBUNTU_ISO_DIR/disk_iso/tmp.img"

# isoでのubuntuの起動可能ディスクを作成
if [[ "$1" == 'initialize=yes' ]]; then
    echo 'start init'

    bash "$_UBUNTU_ISO_DIR/initial_install.sh"

    exit
fi

# 追加のディスクを作成
if [[ "$1" == 'create=yes' ]]; then
    echo 'start create'

    dd if=/dev/zero of=tmp.img bs=1G count=2

    sudo gdisk "$_TMP_IMG_PATH" << (`echo 'n';echo '';echo '';echo '+1G';echo '';echo 'n';echo '';echo '';echo '';echo '';`)

    partprobe

    sudo kpartx -a "$_TMP_IMG_PATH"
fi

# ループバックディスクを取得
_LOOP_BACK_DISK=`losetup | grep "$_TMP_IMG_PATH" | sed -r 's#/dev/(loop[0-9]+) *.*#\1#g' | head -n 1`
if [[ "$_LOOP_BACK_DISK" == '' ]]; then
    echo 'ループバックに設定されていません。'
    exit 1
fi

# 追加のディスクをフォーマット
if [[ "$1" == 'format=yes' ]]; then
    echo 'start format'

    sudo mkfs.ext4 "/dev/mapper/$_LOOP_BACK_DISK"p1
    sudo mkfs.ext4 "/dev/mapper/$_LOOP_BACK_DISK"p2

fi

# 追加のディスクをqcow2へ
if [[ "$1" == 'convert=yes' ]]; then
    echo 'start convert'

    sudo qemu-img convert -f raw -O qcow2 "/dev/mapper/$_LOOP_BACK_DISK"p1 "$_TMP_IMG_PATH"_qcow2_1
    sudo qemu-img convert -f raw -O qcow2 "/dev/mapper/$_LOOP_BACK_DISK"p2 "$_TMP_IMG_PATH"_qcow2_2

    sudo qemu-img convert -f raw -O qcow2 "/dev/$_LOOP_BACK_DISK" "$_TMP_IMG_PATH"_qcow2_x

fi

# 実行
if [[ "$1" == 'exe=yes' ]]; then
    echo 'start exe'

    sudo qemu-system-x86_64 \
        -m 1024 -enable-kvm -cpu host \
        "$_UBUNTU_ISO_DIR/disk_iso/ubuntuOS.qcow2" \
        -drive format=qcow2,media=disk,file="$_TMP_IMG_PATH"_qcow2_1
        -drive format=qcow2,media=disk,file="$_TMP_IMG_PATH"_qcow2_2

fi

# 実行その2
if [[ "$1" == 'exe2=yes' ]]; then
    echo 'start exe2'

    # これも動いた
    # また中への書き込みが保持されていることを確認
    sudo qemu-system-x86_64 \
        -m 1024 -enable-kvm -cpu host \
        "$_UBUNTU_ISO_DIR/disk_iso/ubuntuOS.qcow2" \
        -drive format=qcow2,media=disk,file="$_TMP_IMG_PATH"_qcow2_3

fi
