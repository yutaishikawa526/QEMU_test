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
if [[ "$_DEBSTRAP_KEYRING" == 'no' ]]; then
    keyring='--no-check-gpg'
elif [[ "$_DEBSTRAP_KEYRING" == '' ]]; then
    keyring=''
else
    keyring="--keyring $_DEBSTRAP_KEYRING"
fi

sudo debootstrap \
    --arch riscv64 --foreign \
    "$keyring" \
    --include="$_DEBSTRAP_INCLUDE" \
    "$_DEBSTRAP_SUITE" "$tmp_mnt" \
    "$_DEBSTRAP_URL"

# aptのミラーサイトを設定
echo "$_DEBSTRAP_APT_SOURCE" | sudo sh -c "cat > $tmp_mnt/etc/apt/sources.list"

sleep 3

# アンマウント
umount_all "$tmp_mnt"

# ループバックデバイス解除
unset_device "$_DISK_PATH"
