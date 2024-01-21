#!/bin/bash -e

# diskイメージから実行を行う

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR/sh/install_ubuntu"

# efiとrootのディスクイメージを読み込むために以下を実行
_DIR="$_CREATE_DIR"
source "$_DIR/conf/conf.sh"
_DIR=$(cd $(dirname $0) ; pwd)

#sudo qemu-system-x86_64 \
#    -boot menu=on -m 1024 \
#    -drive file="$_DISK_EFI",format=raw,if=none,id=disk_efi \
#    -device drive=disk_efi,bootindex=1 \
#    -drive file="$_DISK_ROOT",format=raw,if=none,id=disk_root \
#    -device drive=disk_root

#sudo qemu-system-x86_64 \
#    -drive file="$_DISK_EFI",format=raw,if=none,id=disk_efi \
#    -device ide-hd,drive=disk_efi,bootindex=1 \
#    -drive file="$_DISK_ROOT",format=raw,if=none,id=disk_root \
#    -device ide-hd,drive=disk_root

#sudo qemu-system-x86_64 \
#    -boot menu=on -m 1024 \
#    -drive file="$_DISK_EFI",format=raw,media=disk \
#    -drive file="$_DISK_ROOT",format=raw,media=disk

#sudo qemu-img convert -f raw -O qcow2 "$_DISK_EFI" "$_DISK_EFI"_qemu
#sudo qemu-img convert -f raw -O qcow2 "$_DISK_ROOT" "$_DISK_ROOT"_qemu
#sudo qemu-system-x86_64 -hda "$_DISK_EFI"_qemu -hdb "$_DISK_ROOT"_qemu -boot menu=on -m 1024

#sudo qemu-system-x86_64 \
#    -boot menu=on -m 1024 \
#    -drive file="$_DISK_EFI"_qemu,format=qcow2,media=disk,boot=on \
#    -drive file="$_DISK_ROOT"_qemu,format=qcow2,media=disk

#sudo qemu-system-x86_64 \
#    -boot menu=on -m 1024 \
#    -drive file="$_DISK_EFI"_qemu,format=qcow2 \
#    -drive file="$_DISK_ROOT"_qemu,format=qcow2

#sudo qemu-system-x86_64 \
#    -boot menu=on -m 2048 \
#    -drive file="$_DISK_EFI"_qemu,format=qcow2 \
#    -drive file="$_DISK_ROOT"_qemu,format=qcow2

#sudo losetup '/dev/loop29' "$_DISK_EFI"
#sudo losetup '/dev/loop30' "$_DISK_ROOT"
#sudo qemu-system-x86_64 -hda '/dev/loop29' -hdb '/dev/loop30' -boot menu=on -m 1024
#sudo losetup -d '/dev/loop29'
#sudo losetup -d '/dev/loop30'

#sudo losetup '/dev/loop59' "$_DISK_EFI"
#sudo losetup '/dev/loop60' "$_DISK_ROOT"
#sudo qemu-system-x86_64 \
#    -drive file='/dev/loop59',format=raw,id=disk_efi,if=none \
#    -device ide-hd,drive=disk_efi \
#    -drive file='/dev/loop60',format=raw,id=disk_root,if=none \
#    -device ide-hd,drive=disk_root \
#    -boot menu=on -m 1024
#sudo losetup -d '/dev/loop59'
#sudo losetup -d '/dev/loop60'

#sudo qemu-system-x86_64 \
#    -drive file="$_DISK_EFI",format=raw,if=none,id=disk_efi \
#    -device ide-hd,drive=disk_efi,bootindex=1 \
#    -drive file="$_DISK_ROOT",format=raw,if=none,id=disk_root \
#    -device ide-hd,drive=disk_root

#sudo qemu-system-x86_64 -boot menu=on -m 1024 \
#    -drive file='/dev/nvme0n1p1',format=raw,id=disk_nvme1,if=none \
#    -drive file='/dev/nvme0n1p2',format=raw,id=disk_nvme2,if=none \
#    -drive file='/dev/nvme0n1p3',format=raw,id=disk_nvme3,if=none \
#    -drive file='/dev/nvme0n1p4',format=raw,id=disk_nvme4,if=none \
#    -drive file='/dev/nvme0n1p5',format=raw,id=disk_nvme5,if=none \
#    -device virtio-scsi-device,drive=disk_nvme1 \
#    -device virtio-scsi-device,drive=disk_nvme2 \
#    -device virtio-scsi-device,drive=disk_nvme3 \
#    -device virtio-scsi-device,drive=disk_nvme4 \
#    -device virtio-scsi-device,drive=disk_nvme5
#-device nvme-hd,drive=disk_nvme \

#sudo qemu-img convert -f raw -O qcow2 "$_DISK_EFI" "$_DISK_EFI"_qemu
#sudo qemu-img convert -f raw -O qcow2 "$_DISK_ROOT" "$_DISK_ROOT"_qemu
#sudo qemu-system-x86_64 "$_DISK_ROOT"_qemu -hda "$_DISK_EFI"_qemu -boot menu=on -m 1024
