#!/bin/bash -ex

# preinstalledイメージの実行

_DIR=$(cd $(dirname $0) ; pwd)
_PREINST_IMG="$_DIR/disk/preinst_disk.img"
_LIVEINST_IMG="$_DIR/disk/liveinst_disk.img"
_LIVE_TARGET_IMG="$_DIR/disk/live_target_disk.img"
_RISCV_DIR=$(cd "$_DIR/../riscv"; pwd)
source "$_RISCV_DIR/com/com.sh"
export_env "$_RISCV_DIR"
_BOOT_LOADER_PATH="$_OPENSBI_UBOOT_PATH"

is_file "$_BOOT_LOADER_PATH"
is_file "$_PREINST_IMG"

# 起動
qemu-system-riscv64 \
    -machine virt -nographic -m 2048 \
    -bios "$_BOOT_LOADER_PATH" \
    -device virtio-net-device,netdev=eth0 -netdev user,id=eth0 \
    -drive file="$_PREINST_IMG",format=raw,if=virtio
