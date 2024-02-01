#!/bin/busybox sh

# install

mnt_point=$1
if [ "$mnt_point" = '' ]; then
    mnt_point='/mnt'
fi

total_device_uuid=

kernel_ver='5.15.0-25'

total_device=`blkid | grep "$total_device_uuid" | head -n 1 | sed -r 's#^(/dev/[a-z]d[a-z][0-9]+): .*$#\1#g'`

# カーネルインストール
chroot "$mnt_point" << EOF
    apt update
    apt install -y --no-install-recommends \
        linux-image-$kernel_ver-generic \
        linux-headers-$kernel_ver-generic \
        linux-modules-$kernel_ver-generic \
        linux-modules-extra-$kernel_ver-generic
    apt install -y initramfs-tools
    update-initramfs -c -k all
    exit
EOF

# 最小のubuntuのインストール
chroot "$mnt_point" apt install -y --no-install-recommends tzdata locales keyboard-configuration

# 日付、地域、キーボード設定
chroot "$mnt_point" dpkg-reconfigure tzdata
chroot "$mnt_point" dpkg-reconfigure locales
chroot "$mnt_point" dpkg-reconfigure keyboard-configuration

# localhostの指定
chroot "$mnt_point" << EOF
    echo 'localhost' > /etc/hostname
    echo '127.0.0.1 localhost' >> /etc/hosts
    exit
EOF

# rootユーザーの設定
echo "----------- Enter root password -----------"
chroot "$mnt_point" passwd

# grubインストール
chroot "$mnt_point" << EOF
    apt install -y grub-efi-riscv64
    grub-install $total_device --target=riscv64-efi --efi-directory=/boot/efi --boot-directory=/boot
    update-grub
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=""/g' /etc/default/grub
    update-grub
    exit
EOF
