#!/bin/bash -ex

# qcow2のディスクをmountして操作する
# 参考サイト: https://qiita.com/summerwind/items/24927a53e59353db753b

sudo apt install -y qemu-utils
sudo modprobe nbd

_EXCE_DIR=$(cd $(dirname $0) ; pwd)
_CREATED_QCOW2="$_EXCE_DIR/disk/created_qcow2.qcow2"
_MOUNT="$_EXCE_DIR/disk/mnt_created_qcow2"
_NBD_DISK=/dev/nbd0
_BOOT_QCOW2_PATH=`(cd "$_EXCE_DIR/../../iso/iso_CentOS6.4";pwd)`'/disk_iso/CentOS.qcow2'
#_BOOT_QCOW2_PATH=`(cd "$_EXCE_DIR/../../iso/iso_Ubuntu20";pwd)`'/disk_iso/ubuntuOS.qcow2'
#_BOOT_QCOW2_PATH=`(cd "$_EXCE_DIR/../../iso/iso_Ubuntu22_server";pwd)`'/disk_iso/ubuntuOS.qcow2'

sudo mkdir -p "$_MOUNT"

function cqcow2_clear(){
    sudo umount "$1" || true
    sudo qemu-nbd -d "$2" || true
}

cqcow2_clear "$_MOUNT" "$_NBD_DISK"

# qcow2ディスクを作成
sudo qemu-img create -f qcow2 "$_CREATED_QCOW2" 2G

sudo qemu-nbd -c "$_NBD_DISK" "$_CREATED_QCOW2"

# CentOS6.4でテストしていたところ、
# vfatならゲスト側でマウントできた
# xfsは反応なし
# ext4は「EXT4-fs (sdb): conuldn't mount RDWR because of unsupported optional features (400)」と出てマウントできなかった
sudo mkfs.ext4 "$_NBD_DISK"

sudo mount "$_NBD_DISK" "$_MOUNT"

sudo touch "$_MOUNT"/test.txt

echo 'test' | sudo sh -c "cat > '$_MOUNT/test.txt'"

cqcow2_clear "$_MOUNT" "$_NBD_DISK"

echo 'start exe'

sudo qemu-system-x86_64 \
    -m 1024 -enable-kvm -cpu host \
    "$_BOOT_QCOW2_PATH" \
    -drive format=qcow2,media=disk,file="$_CREATED_QCOW2"
