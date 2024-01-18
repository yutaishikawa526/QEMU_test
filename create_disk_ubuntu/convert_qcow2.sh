#!/bin/bash

# ディスクをqcow2形式に変換

DISK_PATH=`pwd`/disk/ubuntu_disk_qcow2.img
RAW_DISK_PATH=`pwd`/disk/ubuntu_disk_raw.img

sudo qemu-img convert -f raw -O qcow2 "$RAW_DISK_PATH" "$DISK_PATH"
