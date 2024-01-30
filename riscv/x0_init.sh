#!/bin/busybox sh

# Make symlinks
/bin/busybox --install -s

echo '------------------ init 1 ------------------'

# Mount system
mount -t devtmpfs  devtmpfs  /dev
mount -t proc      proc      /proc
mount -t sysfs     sysfs     /sys
mount -t tmpfs     tmpfs     /tmp

echo '------------------ init 2 ------------------'

# Busybox TTY fix
setsid cttyhack sh

echo '------------------ init 3 ------------------'

# https://git.busybox.net/busybox/tree/docs/mdev.txt?h=1_32_stable
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s

echo '------------------ init 4 ------------------'

sh