#!/bin/bash -e

# diskイメージの作成を行う

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR/sh/install_ubuntu"

# ディスクの作成
bash "$_CLONE_DIR/1a_create_disk.sh"

# debootstrap
bash "$_CLONE_DIR/2_debootstrap.sh"

# kernelインストール
bash "$_CLONE_DIR/3_kernel_install.sh"

# ユーザー設定
bash "$_CLONE_DIR/4_user_setting.sh"

# grubインストール
bash "$_CLONE_DIR/5_grub_install.sh"

# 念の為バックアップ作成
echo 'バックアップを作成します'
bash "$_CLONE_DIR/91a_create_backup.sh"
