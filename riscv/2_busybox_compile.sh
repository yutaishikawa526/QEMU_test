#!/bin/bash -ex

# busyboxのコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_dir "$_BUSYBOX_SRC"

cd "$_BUSYBOX_SRC";

make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
# enable [Settings]->[Build options]->[static binary]
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc)

sudo cp "$_BUSYBOX_SRC/busybox" "$_BUSYBOX_PATH"

cd "$_DIR"
