#!/bin/bash -ex

# テスト用のコード

sudo apt install -y e2fsprogs

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_OPENSBI_SRC="$_DIR/clone/opensbi"
_DISK_PATH="$_DIR/disk/img.raw"
_KERNEL_PATH="$_DIR/disk/kernelImage"
_BUSYBOX_PATH="$_DIR/disk/busybox"
_OPENSBI_PATH="$_DIR/disk/opensbi"
_INIT_DISK_PATH="$_DIR/disk/init_disk.raw"

_INITRAMFS_PATH="$_DIR/disk/initramfs.cpio.gz"

if [[ ! -e "$_DISK_PATH" ]];then
    dd if=/dev/zero of="$_DISK_PATH" bs=1G count=1
    sudo mkfs.ext4 "$_DISK_PATH"

    # 初期化
    sudo sgdisk --zap-all "$_DISK_PATH";sudo partprobe
    # 作成
    sudo sgdisk --new '1::+100M' "$_DISK_PATH";sudo partprobe
    sudo sgdisk --new "2::+100M" "$_DISK_PATH";sudo partprobe
    sudo sgdisk --new "3::+100M" "$_DISK_PATH";sudo partprobe
    sudo sgdisk --new "4::+100M" "$_DISK_PATH";sudo partprobe
    sudo sgdisk --new "5::+100M" "$_DISK_PATH";sudo partprobe
    # パーティションコード指定
    sudo sgdisk --typecode 1:8300 "$_DISK_PATH";sudo partprobe
    sudo sgdisk --typecode 2:8300 "$_DISK_PATH";sudo partprobe
    sudo sgdisk --typecode 3:8300 "$_DISK_PATH";sudo partprobe
    sudo sgdisk --typecode 4:8300 "$_DISK_PATH";sudo partprobe
    sudo sgdisk --typecode 5:8300 "$_DISK_PATH";sudo partprobe
    # 名前付け
    sudo sgdisk --change-name '1:test1' "$_DISK_PATH";sudo partprobe
    sudo sgdisk --change-name '2:test2' "$_DISK_PATH";sudo partprobe
    sudo sgdisk --change-name '3:test3' "$_DISK_PATH";sudo partprobe
    sudo sgdisk --change-name '4:test4' "$_DISK_PATH";sudo partprobe
    sudo sgdisk --change-name '5:test5' "$_DISK_PATH";sudo partprobe
    # ループバックデバイス化
    sudo kpartx -a "$_DISK_PATH"
    loopback=`sudo losetup | grep "$_DISK_PATH" | sed -r 's#^/dev/(loop[0-9]+) *.*$#\1#g' | head -n 1`
    # フォーマット
    sudo mkfs.ext4 "/dev/mapper/$loopback"p1
    sudo mkfs.ext4 "/dev/mapper/$loopback"p2
    sudo mkfs.ext4 "/dev/mapper/$loopback"p3
    sudo mkfs.ext4 "/dev/mapper/$loopback"p4
    sudo mkfs.ext4 "/dev/mapper/$loopback"p5
    # 掃除
    sudo kpartx -d "/dev/$loopback"
    sudo losetup -d "/dev/$loopback"
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
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0 \
#    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
#    -device virtio-blk-device,drive=hd1

# その13
# [Unable to mount root fs on unknown-block]
# 多分カーネルだからext4がマウントできない
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/sda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,media=disk

# その14
# opensbiを指定
# 動いた
sudo qemu-system-riscv64 -machine virt -m 2048 \
    -kernel "$_KERNEL_PATH" \
    -bios "$_OPENSBI_PATH" \
    -append "root=/dev/vda rw console=ttyS0 init=/init" \
    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
    -device virtio-blk-device,drive=hd1

