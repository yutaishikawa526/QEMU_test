#!/bin/bash -ex

# 初期化
# 必要なパッケージ、ソースコードのインストール

sudo apt update
sudo apt install -y gcc-riscv64-linux-gnu git
sudo apt install -y qemu-system-riscv64
sudo apt install -y debootstrap debian-archive-keyring
# コンパイルに必要
sudo apt install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev \
    gawk build-essential bison flex texinfo gperf libtool patchutils bc \
    zlib1g-dev libexpat-dev

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

if [[ -d "$_LINUX_SRC" ]]; then
    sudo rm -R "$_LINUX_SRC"
fi
if [[ -d "$_BUSYBOX_SRC" ]]; then
    sudo rm -R "$_BUSYBOX_SRC"
fi
if [[ -d "$_OPENSBI_SRC" ]]; then
    sudo rm -R "$_OPENSBI_SRC"
fi
if [[ -d "$_UBOOT_SRC" ]]; then
    sudo rm -R "$_UBOOT_SRC"
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

git clone --depth 1 'https://github.com/riscv-software-src/opensbi' "$_OPENSBI_SRC"
cd "$_OPENSBI_SRC"
git fetch --depth 1 origin 'v1.3'
git checkout -b 'v1_3_head' FETCH_HEAD
cd "$_DIR"

git clone --depth 1 'https://github.com/u-boot/u-boot' "$_UBOOT_SRC"
cd "$_UBOOT_SRC"
git fetch --depth 1 origin 'v2023.10'
git checkout -b 'v2023_10_head' FETCH_HEAD
cd "$_DIR"
