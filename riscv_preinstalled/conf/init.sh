#!/bin/bash -e

# 設定ファイルを読み込む

# $_DIRには[../](riscv_preinstalledディレクトリのフルパス)が指定される

if [[ -e "$_DIR/conf/conf.sh" ]]; then
    source "$_DIR/conf/conf.sh"
else
    source "$_DIR/conf/conf-sample.sh"
fi

if [[ ! -d "$_DISK_DIR" ]] || [[ "$_DISK_DIR" == '' ]]; then
    echo 'ディスクのディレクトリが指定されていません。'
    exit 1
fi

_PREINST_IMG="$_DISK_DIR/preinst_disk.img"
_LIVEINST_IMG="$_DISK_DIR/liveinst_disk.img"
_LIVE_TARGET_IMG="$_DISK_DIR/live_target_disk.img"
_RISCV_DIR=$(cd "$_DIR/../riscv"; pwd)
source "$_RISCV_DIR/com/com.sh"
export_env "$_RISCV_DIR"
_BOOT_LOADER_PATH="$_OPENSBI_UBOOT_PATH"
