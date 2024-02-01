#!/bin/bash -ex

# テスト用のコード

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

_INITRAMFS_PATH="$_DIR/disk/initramfs.cpio.gz"

tmp_disk_path="$_DIR/disk/tmp_img.raw"

if [[ ! -e "$tmp_disk_path" ]];then
    dd if=/dev/zero of="$tmp_disk_path" bs=1G count=1
    sudo mkfs.ext4 "$tmp_disk_path"

    # 初期化
    sudo sgdisk --zap-all "$tmp_disk_path";sudo partprobe
    # 作成
    sudo sgdisk --new '1::+100M' "$tmp_disk_path";sudo partprobe
    sudo sgdisk --new "2::+100M" "$tmp_disk_path";sudo partprobe
    sudo sgdisk --new "3::+100M" "$tmp_disk_path";sudo partprobe
    sudo sgdisk --new "4::+100M" "$tmp_disk_path";sudo partprobe
    sudo sgdisk --new "5::+100M" "$tmp_disk_path";sudo partprobe
    # パーティションコード指定
    sudo sgdisk --typecode 1:8300 "$tmp_disk_path";sudo partprobe
    sudo sgdisk --typecode 2:8300 "$tmp_disk_path";sudo partprobe
    sudo sgdisk --typecode 3:8300 "$tmp_disk_path";sudo partprobe
    sudo sgdisk --typecode 4:8300 "$tmp_disk_path";sudo partprobe
    sudo sgdisk --typecode 5:8300 "$tmp_disk_path";sudo partprobe
    # 名前付け
    sudo sgdisk --change-name '1:test1' "$tmp_disk_path";sudo partprobe
    sudo sgdisk --change-name '2:test2' "$tmp_disk_path";sudo partprobe
    sudo sgdisk --change-name '3:test3' "$tmp_disk_path";sudo partprobe
    sudo sgdisk --change-name '4:test4' "$tmp_disk_path";sudo partprobe
    sudo sgdisk --change-name '5:test5' "$tmp_disk_path";sudo partprobe
    # ループバックデバイス化
    sudo kpartx -a "$tmp_disk_path"
    loopback=`sudo losetup | grep "$tmp_disk_path" | sed -r 's#^/dev/(loop[0-9]+) *.*$#\1#g' | head -n 1`
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
#    -drive file="$tmp_disk_path",format=raw,media=disk

# その2
#sudo qemu-system-riscv64 -nographic -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -initrd "$_INITRAMFS_PATH" \
#    -append "console=ttyS0" \
#    -drive file="$tmp_disk_path",format=raw,media=disk

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
#    -drive file="$tmp_disk_path",format=raw,media=disk,id=hd0 \
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
#    -drive file="$tmp_disk_path",format=raw,media=disk

# その12
# こちらも動く
# また[$tmp_disk_path]も認識して、mountもできる
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0 \
#    -drive file="$tmp_disk_path",format=raw,media=disk,id=hd1 \
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
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -bios "$_OPENSBI_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0 \
#    -drive file="$tmp_disk_path",format=raw,media=disk,id=hd1 \
#    -device virtio-blk-device,drive=hd1

# その15
# メインディスクを指定
# 起動成功とファイルの設置は正常
# x3_debootstrapで[cat: /debootstrap/mirror: No such file or directory]
# カーネルのバージョンが高すぎる?
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -bios "$_OPENSBI_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0 \
#    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
#    -device virtio-blk-device,drive=hd1

# その16
# ネットワークを追加
# x4_chroot_install.shはネイティブに実行する必要があるかも?
# chroot中だとsystemctlがあまり使えないっぽいから
# そのためネットワーク設定ができなさそう
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -bios "$_OPENSBI_PATH" \
#    -append "root=/dev/vda rw console=ttyS0 init=/init" \
#    -drive file="$_INIT_DISK_PATH",format=raw,id=hd0 \
#    -device virtio-blk-device,drive=hd0 \
#    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
#    -device virtio-blk-device,drive=hd1 \
#    -netdev user,id=net0 -device virtio-net-device,netdev=net0

# その17
# main diskをrootで実行
# まだカーネル等のインストールはしていないので、そこは指定
# うまくいっているように見える
# [Failed to mount boot-efi.mount - /boot/efi]
# [See 'systemctl status boot-efi.mount' for details.]
# となって[/boot/efi]がマウントできていない←vfatが問題?
# ネット接続は[{ echo '[Match]';echo 'Name=eth0';echo '[Network]';echo 'DHCP=yes'; } > /etc/systemd/network/ethernet.network]
# と
# resolv.conf設定[{ echo '[network]';echo 'nameserver 8.8.8.8'; } > /etc/resolv.conf]
# をして、その後[systemctl restart systemd-networkd;systemctl enable systemd-networkd;]
# で接続可能になる
# ただしapt updateすると、
# [E: Release file for http://~~ is not valid yet]とでる
# 日付がバグっていると発生するらしい
# [date --set='2024/02/01 18:00:00']とか
#sudo qemu-system-riscv64 -machine virt -m 2048 \
#    -kernel "$_KERNEL_PATH" \
#    -bios "$_OPENSBI_PATH" \
#    -append "root=/dev/vda4 rw console=ttyS0" \
#    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
#    -device virtio-blk-device,drive=hd1 \
#    -netdev user,id=net0 -device virtio-net-device,netdev=net0

# その18
# kernel initramfsをインストール後、直接起動
sudo qemu-system-riscv64 \
    -machine virt -m 2048 \
    -bios "$_OPENSBI_PATH" \
    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
    -device virtio-blk-device,drive=hd1 \
    -netdev user,id=net0 -device virtio-net-device,netdev=net0

