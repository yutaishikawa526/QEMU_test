#!/bin/bash -ex

# カーネルコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_dir "$_LINUX_SRC"

cd "$_LINUX_SRC"

make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc)

sudo cp "$_LINUX_SRC/arch/riscv/boot/Image" "$_KERNEL_PATH"

cd "$_DIR"
