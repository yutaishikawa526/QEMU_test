#!/bin/bash -ex

# busyboxのコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"

(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig)
echo 'here , enable [Settings]->[Build options]->[static binary]'
(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig)
(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc))
