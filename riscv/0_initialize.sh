#!/bin/bash -ex

# 初期化
# 必要なパッケージ、ソースコードのインストール

sudo apt update
sudo apt install -y gcc-riscv64-linux-gnu git
sudo apt install -y qemu-system-riscv64
# コンパイルに必要
sudo apt install -y flex bison

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"
_DISK_PATH="$_DIR/disk/img.raw"

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
