#!/bin/bash -e

# ubuntuの手動インストール手順
# 参考サイト: https://gist.github.com/subrezon/9c04d10635ebbfb737816c5196c8ca24 , https://heywoodlh.io/minimal-ubuntu-install

_DISK=/dev/loop1
_EFI_PART=/dev/mapper/loop1p1
_ROOT_PART=/dev/mapper/loop1p2
_LINUX_KERNEL_VER=5.15.0-25
_LOCALHOST=localhost
_USER=user
_NETWORK_INTERFACE=eth0
_MOUNT_DIR=/mnt/tmp
_GRUB_EFI_PACKAGE=grub-efi-amd64
_GRUB_TARGET=x86_64-efi


# 必要なパッケージの追加
# arch-install-scriptsはarch-chrootをするためのパッケージ
add-apt-repository universe
apt update && apt install -y debootstrap arch-install-scripts



# マウント
mount "$_ROOT_PART" "$_MOUNT_DIR"
mkdir -p "$_MOUNT_DIR"/boot/efi
mount "$_EFI_PART" "$_MOUNT_DIR"/boot/efi

# debootstrapでの最小構成の設置
debootstrap jammy "$_MOUNT_DIR" http://de.archive.ubuntu.com/ubuntu

# fstabの設定
genfstab -U "$_MOUNT_DIR" >> "$_MOUNT_DIR"/etc/fstab

# aptのミラーサイト設定
{
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy           main restricted universe'
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy-security  main restricted universe'
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy-updates   main restricted universe'
} > "$_MOUNT_DIR"/etc/apt/sources.list

# カーネルのインストール
arch-chroot "$_MOUNT_DIR" << EOF
apt update
apt install -y --no-install-recommends linux-{image,headers}-${_LINUX_KERNEL_VER}-generic linux-firmware initramfs-tools efibootmgr
apt install -y vim
exit
EOF

# 日付、地域、キーボードの設定
arch-chroot "$_MOUNT_DIR" << EOF
dpkg-reconfigure tzdata
dpkg-reconfigure locales
dpkg-reconfigure keyboard-configuration
exit
EOF

# localhostの指定
arch-chroot "$_MOUNT_DIR" << EOF
echo ${_LOCALHOST} > /etc/hostname
echo "127.0.0.1 ${_LOCALHOST}" >> /etc/hosts
exit
EOF

# root、ユーザーの設定
echo "root password"
arch-chroot "$_MOUNT_DIR" passwd
echo "user: $_USER password"
arch-chroot "$_MOUNT_DIR" useradd -mG sudo "$_USER"
arch-chroot "$_MOUNT_DIR" passwd "$_USER"

# ネットワーク設定
arch-chroot "$_MOUNT_DIR" << EOF
systemctl enable systemd-networkd
{
    echo '[Match]'
    echo "Name=${_NETWORK_INTERFACE}"
    echo ''
    echo '[Network]'
    echo 'DHCP=yes'
} > /etc/systemd/network/ethernet.network
exit
EOF

# いくつかのパッケージのインストール
arch-chroot "$_MOUNT_DIR" << EOF
apt-get install -y gnome-shell gnome-terminal gdm3 firefox
exit
EOF

# grub設定
arch-chroot "$_MOUNT_DIR" << EOF
apt install -y ${_GRUB_EFI_PACKAGE}
grub-install ${_DISK} --target=${_GRUB_TARGET}
update-grub
exit
EOF

# umount
umount "$_MOUNT_DIR"/boot/efi
umount "$_MOUNT_DIR"

# fin