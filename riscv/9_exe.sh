#!/bin/bash -ex

# 起動

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

sudo qemu-system-riscv64 \
    -machine virt -m "$_QEMU_MEMORY" \
    -bios "$_OPENSBI_UBOOT_PATH" \
    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
    -device virtio-blk-device,drive=hd1 \
    -netdev user,id=net0 -device virtio-net-device,netdev=net0 \
    -nographic
