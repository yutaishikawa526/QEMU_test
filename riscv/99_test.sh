#!/bin/bash -ex

# テスト用のコード

sudo apt install -y e2fsprogs

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"
_KERNEL_PATH="$_DIR/disk/kernelImage"
_BUSYBOX_PATH="$_DIR/disk/busybox"
_INITRAMFS_PATH="$_DIR/disk/initramfs.cpio.gz"
_INIT_DISK_PATH="$_DIR/disk/init_disk.raw"

if [[ ! -e "$_DISK_PATH" ]];then
    dd if=/dev/zero of="$_DISK_PATH" bs=1G count=1
    sudo mkfs.ext4 "$_DISK_PATH"
fi

# 動かなかった
#sudo qemu-system-riscv64 \
#    -nographic -m 2048 -machine virt \
#    -bios none \
#    -kernel "$_KERNEL_PATH" \
#    -drive file="$_DISK_PATH",format=raw,media=disk

# その2
#sudo qemu-system-riscv64 -nographic -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -initrd "$_INITRAMFS_PATH" \
#    -append "console=ttyS0" \
#    -drive file="$_DISK_PATH",format=raw,media=disk

# その3
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -initrd "$_INITRAMFS_PATH" \
#    -append "console=ttyS0"

# その4
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -bios none \
#    -kernel "$_KERNEL_PATH" \
#    -initrd "$_INITRAMFS_PATH" \
#    -append "root=/dev/vda rw console=ttyS0" \
#    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd0 \
#    -device virtio-blk-device,drive=hd0

# その5
# [no working init found. Try passing init= option to kernel]
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 earlycon=sbi keep_bootcon bootmem_debug" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0

# その6
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 earlycon=sbi keep_bootcon bootmem_debug" \
#    -drive file="$_INIT_DISK_PATH",format=raw,media=disk

# その7
#sudo qemu-system-riscv64 \
#    -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda ro console=ttyS0" \
#    -drive file="$_BUSYBOX_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0

# その8
# [Request init /sbin/init failed (error -2)]
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 earlycon=sbi keep_bootcon bootmem_debug init=/sbin/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0

# その9
# Attempted to kill init
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 earlycon=sbi keep_bootcon bootmem_debug init=/bin/busybox" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0

# その10
# 動いた!!!
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 earlycon=sbi keep_bootcon bootmem_debug init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0

# その11
# こちらも動く
# ただし[media=disk]を認識していない
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0 \
#    -drive file="$_DISK_PATH",format=raw,media=disk

# その12
# こちらも動く
# また[$_DISK_PATH]も認識して、mountもできる
sudo qemu-system-riscv64 -machine virt -m 2048 \
    -kernel "$_KERNEL_PATH" \
    -append "root=/dev/vda rw console=ttyS0 init=/init" \
    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
    -device virtio-blk-device,drive=hd1

# その13
# [Unable to mount root fs on unknown-block]
# 多分カーネルだからext4がマウントできない
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/sda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,media=disk

