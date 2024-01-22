#!/bin/bash -e

# diskイメージの作成を行う

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR/sh/install_ubuntu"

# ------------- ディスクの作成 -------------
source "$_DIR/conf/conf_qcow2.sh"

# nbd等のクリア
function cqcow2_clear(){
    sudo umount "$1" || true
    sudo qemu-nbd -d "$2" || true
}

# nbd有効化
sudo modprobe nbd

# ディスク作成
sudo qemu-img create -f qcow2 "$_QCOW2_PATH" "$_QCOW2_SIZE"

# nbd登録
sudo qemu-nbd -d "$_NBD_DISK" || true
sudo qemu-nbd -c "$_NBD_DISK" "$_QCOW2_PATH"

# パーティション作成
# 最初の512Mはefi用、残りをroot用として使用する
sudo gdisk "$_NBD_DISK" << END
    `echo '';echo '';echo 'n';echo '';echo '';echo '+512M';echo 'ef00';echo 'n';echo '';echo '';echo '';echo '';echo 'w';echo 'y';`
END
sudo partprobe

# nbd再登録
sudo qemu-nbd -d "$_NBD_DISK" || true
sudo qemu-nbd -c "$_NBD_DISK" "$_QCOW2_PATH"

# フォーマット
sudo mkfs.vfat "$_NBD_DISK"p1
sudo mkfs.ext4 "$_NBD_DISK"p2

# 設定ファイルのディスクの指定を書き換え
sudo sed -i 's#^_DISK_EFI=.*$#_DISK_EFI='"$_NBD_DISK"'p1#g' "$_CREATE_DIR/conf/conf.sh"
sudo sed -i 's#^_DISK_ROOT=.*$#_DISK_ROOT='"$_NBD_DISK"'p2#g' "$_CREATE_DIR/conf/conf.sh"

# ----------------------------------------

# debootstrap
bash "$_CREATE_DIR/2_debootstrap.sh"

# kernelインストール
bash "$_CREATE_DIR/3_kernel_install.sh"

# ユーザー設定
bash "$_CREATE_DIR/4_user_setting.sh"

# grubインストール
bash "$_CREATE_DIR/5_grub_install.sh"

# nbd解除
sudo qemu-nbd -d "$_NBD_DISK" || true

# バックアップ
sudo cp "$_QCOW2_PATH" "$_QCOW2_PATH"_bkup
