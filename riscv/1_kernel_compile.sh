#!/bin/bash -ex

# カーネルコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"

(cd "$_LINUX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig)
(cd "$_LINUX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc))
