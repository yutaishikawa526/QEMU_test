#!/bin/bash -ex

# 初期ディスクの作成

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_file "$_BUSYBOX_PATH"

if [[ -e "$_INIT_DISK_PATH" ]];then
    sudo rm "$_INIT_DISK_PATH"
fi
dd if=/dev/zero of="$_INIT_DISK_PATH" bs=1M count=32
sudo mkfs.ext4 "$_INIT_DISK_PATH"

tmp_mnt="$_DIR/disk/tmp_mnt"
mkdir -p "$tmp_mnt"
sudo mount "$_INIT_DISK_PATH" "$tmp_mnt"

# 起動用のファイル構成作成
sudo mkdir -p "$tmp_mnt"/{bin,sbin,dev,etc,home,mnt,proc,sys,usr,tmp}
sudo mkdir -p "$tmp_mnt"/usr/{bin,sbin}
sudo mkdir -p "$tmp_mnt"/proc/sys/kernel
(cd "$tmp_mnt"/dev;sudo mknod sda b 8 0)
(cd "$tmp_mnt"/dev;sudo mknod console c 5 1)

# busyboxの設置とinit処理の作成
sudo cp "$_BUSYBOX_PATH" "$tmp_mnt/bin/busybox"
cat "$_DIR/x0_init.sh" | sudo sh -c "cat > $tmp_mnt/init"
sudo chmod +x "$tmp_mnt/bin/busybox"
sudo chmod +x "$tmp_mnt/init"

# debootのシェルの設置
deb_sh="$_DIR/disk/x1_debootstrap.sh"
is_file "$deb_sh" || (sudo umount "$tmp_mnt";false)
sudo cp "$deb_sh" "$tmp_mnt/home"
sudo chmod +x "$tmp_mnt/home/x1_debootstrap.sh"

sudo umount "$tmp_mnt"
