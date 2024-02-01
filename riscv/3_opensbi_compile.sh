#!/bin/bash -ex

# openSBIのコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_dir "$_OPENSBI_SRC"

(cd "$_OPENSBI_SRC";make PLATFORM=generic ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc))

sudo cp "$_OPENSBI_SRC/build/platform/generic/firmware/fw_jump.elf" "$_OPENSBI_PATH"
