#!/bin/bash -ex

# メインディスクのフォーマットとdebootstrap

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_file "$_DISK_PATH"

# ループバックデバイス設定
loopback=`set_device "$_DISK_PATH"`

# フォーマット
set_format "$loopback"

sleep 3

# マウント
tmp_mnt="$_DIR/disk/tmp_mnt_main"
sudo rm -R "$tmp_mnt" || true;mkdir -p "$tmp_mnt"
mount_main_disk "$loopback" "$_DIR/disk/tmp_mnt_main"

# ディスクの準備
sudo debootstrap \
    --arch riscv64 --foreign \
    --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
    --include=debian-archive-keyring,curl,vim \
    sid "$tmp_mnt" \
    'http://deb.debian.org/debian/'

# テスト
#[Invalid Release file, no entry for main/binary-riscv64/Packages]
#sudo ./disk/x2_umount.sh /home/yutaishikawa/work/QEMU_test/riscv/disk/tmp_mnt
#tmp_path='/home/yutaishikawa/work/QEMU_test/riscv/disk/test_deboot';mkdir -p "$tmp_path";sudo rm -R "$tmp_path";mkdir -p "$tmp_path"
#sudo debootstrap --arch riscv64 --foreign \
#    --keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg \
#    --include=debian-ports-archive-keyring sid \
#    "$tmp_path" http://deb.debian.org/debian-ports
#tmp_path='/home/yutaishikawa/work/QEMU_test/riscv/disk/test_deboot';mkdir -p "$tmp_path";sudo rm -R "$tmp_path";mkdir -p "$tmp_path"
#sudo debootstrap \
#    --arch riscv64 --foreign \
#    jammy \
#    "$tmp_path" http://de.archive.ubuntu.com/ubuntu

sleep 3

# アンマウント
umount_all "$tmp_mnt"

# ループバックデバイス解除
unset_device "$_DISK_PATH"
