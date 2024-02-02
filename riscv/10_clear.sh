#!/bin/bash -ex

# 全体を初期化

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

# アンマウント
umount_all "$_DIR/disk/tmp_mnt"
umount_all "$_DIR/disk/tmp_mnt_main"

# ループバックデバイス解除
unset_device "$_DISK_PATH"
unset_device "$_INIT_DISK_PATH"
