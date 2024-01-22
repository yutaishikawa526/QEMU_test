#!/bin/bash -e

# qcow2のディスクを中身を適切に変えてからconvertしたときの中身を確認

_EXCE_DIR=$(cd $(dirname $0) ; pwd)
_DISK_DIR="$_EXCE_DIR/disk"
_MOUNT_1="$_DISK_DIR/mnt1"
_MOUNT_1="$_DISK_DIR/mnt2"

if [[ "$1" == 'create=yes' ]]; then
    echo 'start create'

    dd if=/dev/zero of="$_DISK_DIR/tmp.img" bs=1G count=2

    sudo gdisk "$_DISK_DIR/tmp.img" << (`echo 'n';echo '';echo '';echo '+1G';echo '';echo 'n';echo '';echo '';echo '';echo '';`)

    partprobe
fi

sudo mkdir -p "$_MOUNT_1"
sudo mkdir -p "$_MOUNT_2"

sudo umount "$_MOUNT_1" || true
sudo umount "$_MOUNT_2" || true

sudo kpartx -a "$_DISK_DIR/tmp.img"

_LOOP_BACK_DISK=`losetup | grep "$_DISK_DIR/tmp.img" | sed -r 's#/dev/(loop[0-9]+) *.*#\1#g' | head -n 1`

sudo mkfs.ext4 /dev/"$_LOOP_BACK_DISK"p1
sudo mkfs.ext4 /dev/"$_LOOP_BACK_DISK"p2

sudo mount /dev/"$_LOOP_BACK_DISK"p1 "$_MOUNT_1"
sudo mount /dev/"$_LOOP_BACK_DISK"p2 "$_MOUNT_2"

sudo touch "$_MOUNT_1"/test1.txt
sudo touch "$_MOUNT_1"/test2.txt

echo 'test1' | sudo sh -c "cat > '$_MOUNT_1/test1.txt'"
echo 'test2' | sudo sh -c "cat > '$_MOUNT_2/test2.txt'"

sudo qemu-img convert -f raw -O qcow2 /dev/"$_LOOP_BACK_DISK" "$_DISK_DIR/tmp.qcow2"

sudo umount "$_MOUNT_1"
sudo umount "$_MOUNT_2"
sudo kpartx -d /dev/"$_LOOP_BACK_DISK"
sudo losetup -d /dev/"$_LOOP_BACK_DISK"

sudo qemu-system-x86_64 -m 1024 -enable-kvm -cpu host CentOS.qcow2 -drive format=qcow2,media=disk,file="$_DISK_DIR/tmp.qcow2"


