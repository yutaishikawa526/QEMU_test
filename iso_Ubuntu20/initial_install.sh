#!/bin/bash

# 初回時
# isoダウンロードからディスクイメージ作成、起動まで

_ISO_PATH=`pwd`/disk_iso/ubuntuOS.iso
_QCOW2_PATH=`pwd`/disk_iso/ubuntuOS.qcow2

curl -o 'https://old-releases.ubuntu.com/releases/20.04.4/ubuntu-20.04-beta-desktop-amd64.iso' "$_ISO_PATH" 

qemu-img create -f qcow2 "$_QCOW2_PATH" 32G

qemu-system-x86_64 "$_QCOW2_PATH" \
 -m 1024 -boot order=d -cpu host -enable-kvm \
 -cdrom "$_ISO_PATH"
