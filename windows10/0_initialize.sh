#!/bin/bash

_DIR=$(cd $(dirname $0) ; pwd)
_DISK_DIR="$_DIR/disk"
_WIN10_ISO="$_DISK_DIR/Win10_XXX_lang_x64.iso"
_VIRTIO_WIN_ISO="$_DISK_DIR/virtio-win-XXX.iso"
_DISK_IMG="$_DISK_DIR/win10.qcow2"
_IMG_SIZE="40G"

qemu-img create -f qcow2 "$_DISK_IMG" "$_IMG_SIZE"

sudo qemu-system-x86_64 \
    -machine q35,accel=kvm \
    -m 8192 -cpu host -smp 6 \
    -rtc base=localtime,clock=host \
    -drive file="$_WIN10_ISO",index=0,media=cdrom \
    -drive file="$_VIRTIO_WIN_ISO",index=1,media=cdrom \
    -drive file="$_DISK_IMG",index=2,if=virtio,format=qcow2
