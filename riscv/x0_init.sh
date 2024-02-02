#!/bin/busybox sh

# riscv上で実行される

# Make symlinks
/bin/busybox --install -s

# Mount system
mount -t devtmpfs  devtmpfs  /dev
mount -t proc      proc      /proc
mount -t sysfs     sysfs     /sys
mount -t tmpfs     tmpfs     /tmp

echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
echo ''
echo "exec command '/home/x1_debootstrap.sh'"
echo 'it will start debootstrap second stage'
echo ''
echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'

# Busybox TTY fix
setsid cttyhack sh

# https://git.busybox.net/busybox/tree/docs/mdev.txt?h=1_32_stable
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s

sh
