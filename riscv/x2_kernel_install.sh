#!/bin/bash -ex

# カーネルその他のインストール
# riscv上で実行される

# ネットワーク設定
systemctl enable systemd-networkd
{
    echo ''
    echo '[Match]'
    echo 'Name=eth0'
    echo ''
    echo '[Network]'
    echo 'DHCP=yes'
    echo ''
} > '/etc/systemd/network/ethernet.network'
systemctl restart systemd-networkd

apt update -y

# カーネル
apt install -y linux-{image,headers}-riscv64

# initramfs
apt install -y initramfs-tools
update-initramfs -c -k all

# 日付、言語、キーボード設定用
apt install -y tzdata locales keyboard-configuration

# 日付、言語、キーボードの設定
dpkg-reconfigure tzdata
dpkg-reconfigure locales
dpkg-reconfigure keyboard-configuration
