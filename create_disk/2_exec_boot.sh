#!/bin/bash -e

# diskイメージから実行を行う

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR"

_DISK_PATH="$_DIR/disk/img.raw"

# ディスク切断
bash "$_CREATE_DIR/72a_disconnect_disk.sh"

sudo qemu-system-x86_64 \
    -boot menu=on -m 4096 -enable-kvm -cpu host \
    -drive format=raw,media=disk,file="$_DISK_PATH"
