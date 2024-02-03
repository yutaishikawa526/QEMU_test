#!/bin/bash -ex

# kernelインストールの実行

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_file "$_KERNEL_PATH"
is_file "$_OPENSBI_PATH"
is_file "$_DISK_PATH"

# ---- kernelインストール用のシェルを設置 ----

# ループバックに登録
loopback=`set_device "$_DISK_PATH"`

# rootパーティションのデバイスを取得
root_dev=`name_to_devname "$loopback" 'root'`

# マウント
tmp_mnt="$_DIR/disk/tmp_mnt"
mkdir -p "$tmp_mnt"
sudo mount "$root_dev" "$tmp_mnt"

sudo cp "$_DIR/x2_kernel_install.sh" "$tmp_mnt/root/x2_kernel_install.sh"
sudo chmod +x "$tmp_mnt/root/x2_kernel_install.sh"

sleep 3

# アンマウント
umount_all "$tmp_mnt"

# ディスクの解除
unset_device "$_DISK_PATH"

sleep 1

# ---- 起動 ----

# 起動
# !!!注:rootをUUIDによる指定ができない
sudo qemu-system-riscv64 \
    -machine virt -m "$_QEMU_MEMORY" \
    -kernel "$_KERNEL_PATH" \
    -bios "$_OPENSBI_PATH" \
    -append "root=/dev/vda2 rw console=ttyS0" \
    -drive file="$_DISK_PATH",format=raw,media=disk,id=hd1 \
    -device virtio-blk-device,drive=hd1 \
    -netdev user,id=net0 -device virtio-net-device,netdev=net0 \
    -device virtio-rng-pci \
    -nographic
