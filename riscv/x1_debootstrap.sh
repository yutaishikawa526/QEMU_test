#!/bin/busybox sh

# debootstrapのsecond stageを実行

efi_uuid=
boot_uuid=
root_uuid=
swap_uuid=

mnt_point=$1
if [ "$mnt_point" = '' ]; then
    mnt_point='/mnt'
fi

root_dev=`blkid | grep "$root_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`
boot_dev=`blkid | grep "$boot_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`
efi_dev=`blkid | grep "$efi_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`

# マウント
mount -t ext4 "$root_dev" "$mnt_point"
mount -t ext4 "$boot_dev" "$mnt_point/boot"
mount -t vfat "$efi_dev" "$mnt_point/boot/efi"
mount --bind /dev "$mnt_point/dev"
mount --bind /sys "$mnt_point/sys"
mount --bind /proc "$mnt_point/proc"

# debootstrap
chroot "$mnt_point" << EOF
    /debootstrap/debootstrap --second-stage
EOF

# resolv.confの修正
{
    echo '[network]';
    echo 'nameserver 8.8.8.8';
} > "$mnt_point/etc/resolv.conf"

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

# 日付の設定
nowdate=`date +'%Y/%m/%d %H:%M:%S'`
chroot "$mnt_point" << EOF
    date --set='$nowdate'
EOF
