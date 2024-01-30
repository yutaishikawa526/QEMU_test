#!/bin/bash -ex

# busyboxのコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"
_KERNEL_PATH="$_DIR/disk/kernelImage"
_BUSYBOX_PATH="$_DIR/disk/busybox"
_INITRAMFS_PATH="$_DIR/disk/initramfs.cpio.gz"
_INIT_DISK_PATH="$_DIR/disk/init_disk.raw"

(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig)
echo 'here , enable [Settings]->[Build options]->[static binary]'
(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig)
(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc))

sudo cp "$_BUSYBOX_SRC/busybox" "$_BUSYBOX_PATH"
