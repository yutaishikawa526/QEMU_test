#!/bin/bash

# 共通の処理を実装

# 初回起動時
function initial_install(){
    # isoファイルをダウンロードする場所
    _ISO_PATH=$1
    # qcow2のディスクイメージを設置する場所
    _QCOW2_PATH=$2
    # isoファイルのダウンロードURL
    _ISO_URL=$3

    curl -o "$_ISO_URL" "$_ISO_PATH"

    qemu-img create -f qcow2 "$_QCOW2_PATH" 32G

    qemu-system-x86_64 "$_QCOW2_PATH" \
        -m 1024 -boot order=d -cpu host -enable-kvm \
        -cdrom "$_ISO_PATH"
}

# 初回以降の起動時
function exec_boot(){
    # qcow2のディスクイメージの場所
    _QCOW2_PATH=$1

    qemu-system-x86_64 "$_QCOW2_PATH" \
        -enable-kvm -cpu host -m 1024
}