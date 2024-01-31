#!/bin/busybox sh

# インストールの全実行

mnt_point=/mnt
if [ "$mnt_point" = '' ]; then
    mnt_point='/mnt'
fi

./x1_mount_by_uuid.sh "$mnt_point"

./x3_debootstrap.sh "$mnt_point"

./x4_chroot_install.sh "$mnt_point"

./x2_umount.sh "$mnt_point"
