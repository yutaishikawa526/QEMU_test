#!/bin/bash -e

# diskイメージの作成とフォーマット
# ループバックデバイス登録も行う

RAW_DISK_PATH=`pwd`/disk/ubuntu_disk_raw.img

dd if=/dev/zero of="$RAW_DISK_PATH" bs=1G count=32
sudo gdisk "$RAW_DISK_PATH"

sudo partprobe

sudo kpartx "$RAW_DISK_PATH" -a

echo 'パーティションの候補'
losetup | grep "$RAW_DISK_PATH" \
| sed -r 's#^.*(/dev/loop[0-9]+).*$#\1#g' \
| xargs -I loop_num sudo fdisk -l "loop_num"

echo "efiパーティションを選択してください。"
read -p ":" _EFI_DISK

echo "rootパーティションを選択してください。"
read -p ":" _ROOT_DISK

# パーティションのフォーマット
sudo mkfs.vfat "$_EFI_DISK"
sudo mkfs.ext4 "$_ROOT_DISK"
