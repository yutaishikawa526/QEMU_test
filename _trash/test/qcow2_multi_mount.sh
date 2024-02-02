#!/bin/bash -ex

# qcow2のディスクをmountして操作する
# 対象のディスクを複数パーティションを設定して行う

# これらは全て正常に動作した
# ポイントは[sudo qemu-nbd -c]の後で[gdisk]でパーティション作成し、その後でフォーマットするという順番が大切

sudo apt install -y qemu-utils
sudo modprobe nbd

_EXCE_DIR=$(cd $(dirname $0) ; pwd)
_CREATED_QCOW2="$_EXCE_DIR/disk/multi_created_qcow2.qcow2"
_MOUNT_1="$_EXCE_DIR/disk/mnt1_multi_created_qcow2"
_MOUNT_2="$_EXCE_DIR/disk/mnt2_multi_created_qcow2"
_NBD_DISK=/dev/nbd0
#_BOOT_QCOW2_PATH=`(cd "$_EXCE_DIR/../../iso/iso_CentOS6.4";pwd)`'/disk_iso/CentOS.qcow2'
#_BOOT_QCOW2_PATH=`(cd "$_EXCE_DIR/../../iso/iso_Ubuntu20";pwd)`'/disk_iso/ubuntuOS.qcow2'
_BOOT_QCOW2_PATH=`(cd "$_EXCE_DIR/../../iso/iso_Ubuntu22_server";pwd)`'/disk_iso/ubuntuOS.qcow2'

sudo mkdir -p "$_MOUNT_1"
sudo mkdir -p "$_MOUNT_2"

function cqcow2_clear(){
    sudo umount "$1" || true
    sudo umount "$2" || true
    sudo qemu-nbd -d "$3" || true
}

cqcow2_clear "$_MOUNT_1" "$_MOUNT_2" "$_NBD_DISK"

# qcow2ディスクを作成
sudo qemu-img create -f qcow2 "$_CREATED_QCOW2" 2G

sudo qemu-nbd -c "$_NBD_DISK" "$_CREATED_QCOW2"

sudo gdisk "$_NBD_DISK" << END
    `echo '';echo '';echo 'n';echo '';echo '';echo '+1G';echo '';echo 'n';echo '';echo '';echo '';echo '';echo 'w';echo 'y';`
END
sudo partprobe

cqcow2_clear "$_MOUNT_1" "$_MOUNT_2" "$_NBD_DISK"

sudo qemu-nbd -c "$_NBD_DISK" "$_CREATED_QCOW2"

sudo mkfs.ext4 "$_NBD_DISK"p1
sudo mkfs.ext4 "$_NBD_DISK"p2

sudo mount "$_NBD_DISK"p1 "$_MOUNT_1"
sudo mount "$_NBD_DISK"p2 "$_MOUNT_2"

sudo touch "$_MOUNT_1"/test.txt
sudo touch "$_MOUNT_2"/test.txt

echo 'test1_multi_mount' | sudo sh -c "cat > '$_MOUNT_1/test.txt'"
echo 'test2_multi_mount' | sudo sh -c "cat > '$_MOUNT_2/test.txt'"

cqcow2_clear "$_MOUNT_1" "$_MOUNT_2" "$_NBD_DISK"

echo 'start exe'

sudo qemu-system-x86_64 \
    -m 4096 -enable-kvm -cpu host \
    "$_BOOT_QCOW2_PATH" \
    -drive format=qcow2,media=disk,file="$_CREATED_QCOW2"
