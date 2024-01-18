#!/bin/bash

# diskイメージの作成とフォーマット
# ループバックデバイス登録も行う

RAW_DISK_PATH=`pwd`/disk/ubuntu_disk_raw.img

dd if=/dev/zero of="$RAW_DISK_PATH" bs=1G count=32
sudo gdisk "$RAW_DISK_PATH"

sudo partprobe

sudo mkfs.vfat "$_EFI_PART"
sudo mkfs.ext4 "$_ROOT_PART"

sudo kpartx "$RAW_DISK_PATH" -a
