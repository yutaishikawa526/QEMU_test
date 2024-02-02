#!/bin/bash -ex

# メインディスクの作成

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

# ディスクイメージファイル作成
dd if=/dev/zero of="$_DISK_PATH" bs=256M count=33

# ループバックデバイス設定
loopback=`set_device "$_DISK_PATH"`

# パーティション分け
set_partion "$loopback" '2G' '4G' '2G'

sleep 3

# ループバックデバイス解除
unset_device "$_DISK_PATH"
