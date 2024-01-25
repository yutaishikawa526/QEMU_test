#!/bin/bash -e

# diskイメージの作成を行う

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR/sh/install_ubuntu"

# ------------- ディスクの作成 -------------

# ディスクファイル作成
bash "$_CREATE_DIR/1a_create_disk.sh"

# debootstrap
bash "$_CREATE_DIR/2_debootstrap.sh"

# kernelインストール
bash "$_CREATE_DIR/3_kernel_install.sh"

# ユーザー設定
bash "$_CREATE_DIR/4_user_setting.sh"

# grubインストール
bash "$_CREATE_DIR/5_grub_install.sh"

# ----------------------------------------------
# 中身の修正
#_Q_DIR=$_DIR
#_DIR=$_CREATE_DIR
#source "$_DIR/conf/conf.sh"
#source "$_DIR/conf/conf_mnt.sh"
# "$_DIR/com/com.sh"

# マウント
#bash "$_DIR/com/mount.sh"
#bash "$_DIR/com/sys_setup.sh"

# grub.cfgの修正
#uuid=`get_uuid_by_device $_PAT_ROOT`
#sudo sed -i 's#'$_PAT_ROOT'#'$uuid'#g' "$_MNT_POINT/boot/grub/grub.cfg"

# 初期化シェルのコピー
#sudo cp "$_Q_DIR/100_guest_init.sh" "$_MNT_POINT/root/initialize.sh"

# unmount
#bash "$_DIR/com/unset.sh"
#_DIR=$_Q_DIR
# ----------------------------------------------

# ディスク切断
bash "$_CREATE_DIR/72a_disconnect_disk.sh"
