#!/bin/busybox sh

# debootstrapのsecond stage

efi_uuid=
boot_uuid=
root_uuid=
swap_uuid=

mnt_point=$1
if [ "$mnt_point" = '' ]; then
    mnt_point='/mnt'
fi

# debootstrap
chroot "$mnt_point" << EOF
    /debootstrap/debootstrap --second-stage
EOF

# fstabの設定
{
    echo '# root'
    echo "UUID=$root_uuid / ext4 defaults 0 1"
    echo '# boot'
    echo "UUID=$boot_uuid /boot ext4 defaults 0 2"
    echo '# efi'
    echo "UUID=$efi_uuid /boot/efi vfat defaults 0 2"
    if [ ! $swap_uuid = '' ]; then
        echo '# swap'
        echo "UUID=$swap_uuid none swap defaults 0 0"
    fi
} > "$mnt_point/etc/fstab"

# aptのミラーサイト設定
{
    echo 'deb http://deb.debian.org/debian/ sid main'
    echo 'deb http://deb.debian.org/debian/ unstable main'
    echo 'deb http://deb.debian.org/debian/ experimental main'
} > "$mnt_point/etc/apt/sources.list"
