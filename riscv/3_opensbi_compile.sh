#!/bin/bash -ex

# openSBIのコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_OPENSBI_SRC="$_DIR/clone/opensbi"
_DISK_PATH="$_DIR/disk/img.raw"
_KERNEL_PATH="$_DIR/disk/kernelImage"
_BUSYBOX_PATH="$_DIR/disk/busybox"
_OPENSBI_PATH="$_DIR/disk/opensbi"
_INIT_DISK_PATH="$_DIR/disk/init_disk.raw"

(cd "$_OPENSBI_SRC";make PLATFORM=generic ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc))

sudo cp "$_OPENSBI_SRC/build/platform/generic/firmware/fw_jump.elf" "$_OPENSBI_PATH"
