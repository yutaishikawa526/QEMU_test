#!/bin/bash -ex

# busyboxのコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig)
echo 'here , enable [Settings]->[Build options]->[static binary]'
(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig)
(cd "$_BUSYBOX_SRC";make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc))

sudo cp "$_BUSYBOX_SRC/busybox" "$_BUSYBOX_PATH"
