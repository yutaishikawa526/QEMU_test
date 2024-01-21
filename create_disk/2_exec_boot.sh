#!/bin/bash -e

# diskイメージから実行を行う

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR/sh/install_ubuntu"

# efiとrootのディスクイメージを読み込むために以下を実行
_DIR="$_CREATE_DIR"
source "$_DIR/conf/conf.sh"
_DIR=$(cd $(dirname $0) ; pwd)

sudo qemu-system-x86_64 "$_QCOW2_PATH" \
    -boot menu=on -enable-kvm -cpu host -m 1024 \
    -drive file="$_DISK_EFI" \
    -drive file="$_DISK_ROOT"
