#!/bin/bash -ex

# テスト用のコード

sudo apt install -y e2fsprogs

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"

if [[ -e "$_DISK_PATH" ]];then
    sudo rm "$_DISK_PATH"
fi
dd if=/dev/zero of="$_DISK_PATH" bs=1G count=1
sudo mkfs.ext4 "$_DISK_PATH"

sudo qemu-system-riscv64 \
    -nographic -m 2048 -machine virt \
    -bios none \
    -kernel "$_LINUX_SRC/arch/riscv/boot/Image" \
    -drive file="$_DISK_PATH",format=raw,media=disk
