#!/bin/bash -ex

# カーネルコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"
_KERNEL_PATH="$_DIR/disk/kernelImage"
_BUSYBOX_PATH="$_DIR/disk/busybox"
_INITRAMFS_PATH="$_DIR/disk/initramfs.cpio.gz"
_INIT_DISK_PATH="$_DIR/disk/init_disk.raw"

(cd "$_LINUX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig)
(cd "$_LINUX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig)
(cd "$_LINUX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc))

sudo cp "$_LINUX_SRC/arch/riscv/boot/Image" "$_KERNEL_PATH"
