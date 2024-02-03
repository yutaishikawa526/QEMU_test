#!/bin/busybox sh

# debootstrapのsecond stageを実行
# riscv上で実行される

boot_uuid=
root_uuid=
swap_uuid=

mnt_point=$1
if [ "$mnt_point" = '' ]; then
    mnt_point='/mnt'
fi

root_dev=`blkid | grep "$root_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`
boot_dev=`blkid | grep "$boot_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`

echo '--------- start mount ---------'

# マウント
mount -t ext4 "$root_dev" "$mnt_point"
mount -t ext4 "$boot_dev" "$mnt_point/boot"
mount --bind /dev "$mnt_point/dev"
mount --bind /sys "$mnt_point/sys"
mount --bind /proc "$mnt_point/proc"

echo '--------- start debootstrap ---------'

# debootstrap
if [[ -d "$mnt_point/debootstrap" ]]; then
    chroot "$mnt_point" /debootstrap/debootstrap --second-stage
else
    echo 'already debootstrap'
fi

echo '--------- set password ---------'

echo "Enter root password"
chroot "$mnt_point" passwd

echo '--------- set date and time ---------'

# 日付の設定
nowdate=`date +'%Y/%m/%d %H:%M:%S'`
chroot "$mnt_point" date --set="$nowdate"

echo '--------- set fstab ---------'

# fstabの設定
{
    echo '# root'
    echo "UUID=$root_uuid / ext4 defaults 0 1"
    echo '# boot'
    echo "UUID=$boot_uuid /boot ext4 defaults 0 2"
    if [[ $swap_uuid != '' ]]; then
        echo '# swap'
        echo "UUID=$swap_uuid none swap defaults 0 0"
    fi
} > "$mnt_point/etc/fstab"

echo '--------- set resolv.conf ---------'

# resolv.confの設定
{
    echo '[network]';
    echo 'nameserver 8.8.8.8';
} > "$mnt_point/etc/resolv.conf"
