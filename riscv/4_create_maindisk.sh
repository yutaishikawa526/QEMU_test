#!/bin/bash -ex

# メインディスクの作成

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

# ディスクイメージファイル作成
dd if=/dev/zero of="$_DISK_PATH" bs=512M count=$_DISK_TOTAL_SIZE

# ループバックデバイス設定
loopback=`set_device "$_DISK_PATH"`

# パーティション分け
set_partion "$loopback" "$_DISK_BOOT_SIZE" "$_DISK_ROOT_SIZE" "$_DISK_SWAP_SIZE"

sleep 3

# ループバックデバイス解除
unset_device "$_DISK_PATH"
