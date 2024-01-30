#!/bin/bash -ex

# initramfsの作成

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"
_KERNEL_PATH="$_DIR/disk/kernelImage"
_BUSYBOX_PATH="$_DIR/disk/busybox"
_INITRAMFS_PATH="$_DIR/disk/initramfs.cpio.gz"

if [[ ! -e "$_BUSYBOX_PATH" ]]; then
    echo 'busybox not exist . compile it by 2_busybox_compile.sh'
    exit 1
fi
if [[ -e "$_INITRAMFS_PATH" ]]; then
    sudo rm "$_INITRAMFS_PATH"
fi

tmp_initramfs_dir="$_DIR/disk/tmp_initramfs"
if [[ -d "$tmp_initramfs_dir" ]]; then
    sudo rm -R "$tmp_initramfs_dir"
fi
mkdir -p "$tmp_initramfs_dir"

mkdir -p "$tmp_initramfs_dir"/{bin,sbin,dev,etc,home,mnt,proc,sys,usr,tmp}
mkdir -p "$tmp_initramfs_dir"/usr/{bin,sbin}
mkdir -p "$tmp_initramfs_dir"/proc/sys/kernel
(cd "$tmp_initramfs_dir"/dev;sudo mknod sda b 8 0)
(cd "$tmp_initramfs_dir"/dev;sudo mknod console c 5 1)
sudo cp "$_BUSYBOX_PATH" "$tmp_initramfs_dir"/bin/busybox

sudo touch "$tmp_initramfs_dir"/
cat "$_DIR/x0_init.sh" | sudo sh -c "cat > $tmp_initramfs_dir/init"

sudo chmod +x "$tmp_initramfs_dir"/bin/busybox
sudo chmod +x "$tmp_initramfs_dir"/init

find "$tmp_initramfs_dir" -print0 | cpio --null -ov --format=newc | gzip -9 > "$_INITRAMFS_PATH"

sudo rm -R "$tmp_initramfs_dir"
