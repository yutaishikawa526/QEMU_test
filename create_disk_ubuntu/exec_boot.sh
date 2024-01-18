#!/bin/bash

# ディスクを実行

DISK_PATH=`pwd`/disk/ubuntu_disk_qcow2.img

sudo qemu-system-x86_64 "$DISK_PATH" -enable-kvm -m 1024 -cpu host
