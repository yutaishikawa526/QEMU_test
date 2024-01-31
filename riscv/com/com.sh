#!/bin/bash -e

# 共通の処理を定義

# 環境変数をexportする
# @param $1 トップディレクトリのフルパス(riscvディレクトリのフルパス)
function export_env(){
    top_dir=$1

    if [[ ! -d "$top_dir" ]]; then
        echo 'トップディレクトリの指定が適切でありません。1'
        exit 1
    fi
    if [[ ! "$top_dir" =~ ^.*/riscv$ ]]; then
        echo 'トップディレクトリの指定が適切でありません。2'
        exit 1
    fi

    _LINUX_SRC="$top_dir/clone/linux"
    _BUSYBOX_SRC="$top_dir/clone/busyBox"
    _OPENSBI_SRC="$top_dir/clone/opensbi"

    _KERNEL_PATH="$top_dir/disk/kernelImage"
    _BUSYBOX_PATH="$top_dir/disk/busybox"
    _OPENSBI_PATH="$top_dir/disk/opensbi"

    _INIT_DISK_PATH="$top_dir/disk/init_disk.raw"
    _DISK_PATH="$top_dir/disk/img.raw"

    _COM_DIR="$top_dir/com"

    export _LINUX_SRC
    export _BUSYBOX_SRC
    export _OPENSBI_SRC

    export _KERNEL_PATH
    export _BUSYBOX_PATH
    export _OPENSBI_PATH

    export _INIT_DISK_PATH
    export _DISK_PATH

    export _COM_DIR
}


