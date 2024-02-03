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

# パーティション毎のデバイスを取得
boot_dev=`name_to_devname "$loopback" 'boot'`
root_dev=`name_to_devname "$loopback" 'root'`
swap_dev=`name_to_devname "$loopback" 'swap'`

# マウント
tmp_mnt="$_DIR/disk/tmp_mnt_main"
sudo rm -R "$tmp_mnt" || true
mkdir -p "$tmp_mnt"

sudo mkdir -p "$tmp_mnt"
sudo mount -t ext4 "$root_dev" "$tmp_mnt"
sudo mkdir -p "$tmp_mnt/boot"
sudo mount -t ext4 "$boot_dev" "$tmp_mnt/boot"

# debootstrap first stage
sudo debootstrap \
    --arch riscv64 --foreign \
    --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
    --include=debian-archive-keyring,curl,vim \
    sid "$tmp_mnt" \
    'http://deb.debian.org/debian/'

# aptのミラーサイトを設定
{
    echo 'deb http://deb.debian.org/debian/ sid main'
    echo 'deb http://deb.debian.org/debian/ unstable main'
    echo 'deb http://deb.debian.org/debian/ experimental main'
} | sudo sh -c "cat > $tmp_mnt/etc/apt/sources.list"

sleep 3

# アンマウント
umount_all "$tmp_mnt"

# ループバックデバイス解除
unset_device "$_DISK_PATH"
