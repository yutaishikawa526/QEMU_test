#!/bin/bash -ex

# 初期ディスクの作成

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

if [[ ! -e "$_BUSYBOX_PATH" ]]; then
    echo 'busybox not exist . compile it by 2_busybox_compile.sh'
    exit 1
fi

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
sudo cp "$_BUSYBOX_PATH" "$tmp_mnt"/bin/busybox

sudo touch "$tmp_mnt"/init
cat "$_DIR/x0_init.sh" | sudo sh -c "cat > $tmp_mnt/init"

sudo chmod +x "$tmp_mnt"/bin/busybox
sudo chmod +x "$tmp_mnt"/init

sudo umount "$tmp_mnt"
