#!/bin/busybox sh

# debootstrapのsecond stage

efi_uuid=
boot_uuid=
root_uuid=
swap_uuid=

mnt_point=$1

# debootstrap
eval "$mnt_point/debootstrap/debootstrap --second-stage"

# fstabの設定
{
    echo '# root'
    echo "UUID=$root_uuid / ext4 defaults 0 1"
    echo '# boot'
    echo "UUID=$boot_uuid /boot ext4 defaults 0 2"
    echo '# efi'
    echo "UUID=$efi_uuid /boot/efi vfat defaults 0 2"
    if [[ $swap_uuid != '' ]]; then
        echo '# swap'
        echo "UUID=$swap_uuid none swap defaults 0 0"
    fi
} > "$mnt_point/etc/fstab"

# aptのミラーサイト設定
{
    echo 'deb http://ftp.ports.debian.org/debian-ports jammy           main restricted universe'
    echo 'deb http://ftp.ports.debian.org/debian-ports jammy-security  main restricted universe'
    echo 'deb http://ftp.ports.debian.org/debian-ports jammy-updates   main restricted universe'
} > "$mnt_point/etc/apt/sources.list"
