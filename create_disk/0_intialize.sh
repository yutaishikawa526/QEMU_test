#!/bin/bash -e

# 必要なgit repositoryの設置

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR/sh/install_ubuntu"

sudo apt update
sudo apt install -y git qemu-kvm

# 必要ならば
# sudo apt install -y libvirt-daemon bridge-utils virt-manager

# 必要なリポジトリのダウンロード
git clone https://github.com/yutaishikawa526/UbuntuSettings "$_CLONE_DIR"
sudo rm -R "$_CLONE_DIR/.git"

# 設定ファイルの設置
ubuntu_conf_path="$_DIR/conf/conf_UbuntuSettings.sh"
if [ ! -e "$ubuntu_conf_path" ]; then
    echo 'UbuntuSettings用の設定ファイルがありません。'
    exit 1
fi

sudo cp "$ubuntu_conf_path" "$_CREATE_DIR/conf/conf.sh"

sudo chmod 744 -R "$_CREATE_DIR"
