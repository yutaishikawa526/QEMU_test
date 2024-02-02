#!/bin/bash -ex

# 初期化
# 必要なパッケージのインストール
# 公式のイメージのダウンロード&解凍
# 「openSBI + U-boot」ブートローダー作成

sudo apt update
sudo apt install -y qemu-system-riscv64 qemu-kvm qemu-utils xz-utils gzip

_DIR=$(cd $(dirname $0) ; pwd)
_PREINST_IMG="$_DIR/disk/preinst_disk.img"
_LIVEINST_IMG="$_DIR/disk/liveinst_disk.img"
_LIVE_TARGET_IMG="$_DIR/disk/live_target_disk.img"
_RISCV_DIR=$(cd "$_DIR/../riscv"; pwd)
source "$_RISCV_DIR/com/com.sh"
export_env "$_RISCV_DIR"
_BOOT_LOADER_PATH="$_OPENSBI_UBOOT_PATH"

# ブートローダー作成
if [[ ! -e "$_BOOT_LOADER_PATH" ]]; then
    bash "$_RISCV_DIR/0_initialize.sh"
    bash "$_RISCV_DIR/3_opensbi_compile.sh"
fi

# Liveインストールイメージのダウンロード
if [[ ! -e "$_LIVEINST_IMG" ]]; then
    url='https://cdimage.ubuntu.com/releases/22.04.3/release/ubuntu-22.04.3-live-server-riscv64.img.gz'
    curl "$url" -o "$_LIVEINST_IMG"'.gz'
    gzip -d "$_LIVEINST_IMG"'.gz'
    dd if=/dev/zero of="$_LIVE_TARGET_IMG" bs=1M count=1 seek="`expr 1024 \* 16`"
fi

# preinstalledイメージのダウンロード
if [[ ! -e "$_PREINST_IMG" ]]; then
    url='https://cdimage.ubuntu.com/releases/22.04.3/release/ubuntu-22.04.3-preinstalled-server-riscv64+unmatched.img.xz'
    curl "$url" -o "$_PREINST_IMG"'.xz'
    xz -dk "$_PREINST_IMG"'.xz'
    qemu-img resize -f raw "$_PREINST_IMG" +5G
fi
