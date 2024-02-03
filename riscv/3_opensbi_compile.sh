#!/bin/bash -ex

# uboot付きのopenSBIのコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_dir "$_OPENSBI_SRC"
is_dir "$_UBOOT_SRC"

# ubootのコンパイル
cd "$_UBOOT_SRC"
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- qemu-riscv64_smode_defconfig
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc)

sleep 3

# uboot付き
# [https://github.com/riscv-software-src/opensbi/blob/v1.3/docs/platform/qemu_virt.md]
cd "$_OPENSBI_SRC"
make PLATFORM=generic ARCH=riscv \
    FW_PAYLOAD_PATH="$_UBOOT_SRC/u-boot.bin" \
    CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc)

sudo cp "$_OPENSBI_SRC/build/platform/generic/firmware/fw_jump.elf" "$_OPENSBI_PATH"

sudo cp "$_OPENSBI_SRC/build/platform/generic/firmware/fw_payload.elf" "$_OPENSBI_UBOOT_PATH"

cd "$_DIR"
