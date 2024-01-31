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

sudo mkdir -p "$tmp_mnt"/{bin,sbin,dev,etc,home,mnt,proc,sys,usr,tmp}
sudo mkdir -p "$tmp_mnt"/usr/{bin,sbin}
sudo mkdir -p "$tmp_mnt"/proc/sys/kernel
(cd "$tmp_mnt"/dev;sudo mknod sda b 8 0)
(cd "$tmp_mnt"/dev;sudo mknod console c 5 1)
sudo cp "$_BUSYBOX_PATH" "$tmp_mnt/bin/busybox"

sudo touch "$tmp_mnt/init"
cat "$_DIR/x0_init.sh" | sudo sh -c "cat > $tmp_mnt/init"

tmp_sh1="$_DIR/disk/x1_mount_by_uuid.sh"
tmp_sh2="$_DIR/disk/x2_umount.sh"
tmp_sh3="$_DIR/disk/x3_debootstrap.sh"
tmp_sh4="$_DIR/disk/x4_chroot_install.sh"
tmp_sh5="$_DIR/disk/x5_main.sh"
is_file "$tmp_sh1" || (sudo umount "$tmp_mnt";false)
is_file "$tmp_sh2" || (sudo umount "$tmp_mnt";false)
is_file "$tmp_sh3" || (sudo umount "$tmp_mnt";false)
is_file "$tmp_sh4" || (sudo umount "$tmp_mnt";false)
is_file "$tmp_sh5" || (sudo umount "$tmp_mnt";false)
sudo cp "$tmp_sh1" "$tmp_mnt/home"
sudo cp "$tmp_sh2" "$tmp_mnt/home"
sudo cp "$tmp_sh3" "$tmp_mnt/home"
sudo cp "$tmp_sh4" "$tmp_mnt/home"
sudo cp "$tmp_sh5" "$tmp_mnt/home"

sudo chmod +x "$tmp_mnt/bin/busybox"
sudo chmod +x "$tmp_mnt/init"
sudo chmod +x "$tmp_mnt/home" -R

sudo umount "$tmp_mnt"
