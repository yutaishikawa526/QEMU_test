#!/bin/bash

_DIR=$(cd $(dirname $0) ; pwd)
_DISK_DIR="$_DIR/disk"
_DISK_IMG="$_DISK_DIR/win10.qcow2"

qemu-system-x86_64 \
    -machine q35,accel=kvm \
    -m 8192 -cpu host -smp 6 \
    -rtc base=localtime,clock=host \
    -drive file="$_DISK_IMG",if=virtio,format=qcow2 \
    -audiodev pa,id=sound_dev \
    -device intel-hda \
    -device hda-duplex,audiodev=sound_dev

## sudoをつけるとサウンドカードがうまく認識しない
