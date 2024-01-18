#!/bin/bash

# 初回時
# isoダウンロードからディスクイメージ作成、起動まで

_ISO_PATH=`pwd`/disk_iso/CentOS.iso
_QCOW2_PATH=`pwd`/disk_iso/CentOS.qcow2

curl -o 'https://ftp.jaist.ac.jp/pub/Linux/CentOS-vault/6.4/isos/x86_64/CentOS-6.4-x86_64-minimal.iso' "$_ISO_PATH" 

qemu-img create -f qcow2 "$_QCOW2_PATH" 32G

qemu-system-x86_64 "$_QCOW2_PATH" \
 -m 1024 -boot order=d -cpu host -enable-kvm \
 -cdrom "$_ISO_PATH"
