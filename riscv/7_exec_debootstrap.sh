#!/bin/bash -ex

# debootstrap second stageの実行

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_file "$_KERNEL_PATH"
is_file "$_OPENSBI_PATH"
is_file "$_INIT_DISK_PATH"
is_file "$_DISK_PATH"

# 起動
sudo qemu-system-riscv64 \
    -machine virt -m "$_QEMU_MEMORY" \
    -kernel "$_KERNEL_PATH" \
    -bios "$_OPENSBI_PATH" \
    -append "root=/dev/vda rw console=ttyS0 init=/init" \
    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
    -device virtio-blk-device,drive=hd1 \
    -netdev user,id=net0 -device virtio-net-device,netdev=net0 \
    -device virtio-rng-pci \
    -nographic
