#!/bin/bash -ex

# preinstalledイメージの実行

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/conf/init.sh"

is_file "$_BOOT_LOADER_PATH"
is_file "$_PREINST_IMG"

# 起動
sudo qemu-system-riscv64 \
    -machine virt -nographic -m 2048 \
    -bios "$_BOOT_LOADER_PATH" \
    -device virtio-net-device,netdev=eth0 -netdev user,id=eth0 \
    -drive file="$_PREINST_IMG",format=raw,if=virtio
