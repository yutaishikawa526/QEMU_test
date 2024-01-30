#!/bin/bash -ex

# 初期化
# 必要なパッケージ、ソースコードのインストール

sudo apt update
sudo apt install -y gcc-riscv64-linux-gnu git
sudo apt install -y qemu-system-riscv64
# コンパイルに必要
sudo apt install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev \
    gawk build-essential bison flex texinfo gperf libtool patchutils bc \
    zlib1g-dev libexpat-dev

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"
_KERNEL_PATH="$_DIR/disk/kernelImage"
_BUSYBOX_PATH="$_DIR/disk/busybox"
_INITRAMFS_PATH="$_DIR/disk/initramfs.cpio.gz"
_INIT_DISK_PATH="$_DIR/disk/init_disk.raw"

if [[ -d "$_LINUX_SRC" ]]; then
    sudo rm -R "$_LINUX_SRC"
fi
if [[ -d "$_BUSYBOX_SRC" ]]; then
    sudo rm -R "$_BUSYBOX_SRC"
fi

git clone --depth 1 'https://github.com/torvalds/linux.git' "$_LINUX_SRC"
cd "$_LINUX_SRC"
git fetch --depth 1 origin 'v5.15'
git checkout -b 'v5_15_head' FETCH_HEAD
cd "$_DIR"

git clone --depth 1 'https://git.busybox.net/busybox' "$_BUSYBOX_SRC"
cd "$_BUSYBOX_SRC"
git fetch --depth 1 origin '1_34_1'
git checkout -b '1_34_1_head' FETCH_HEAD
cd "$_DIR"
