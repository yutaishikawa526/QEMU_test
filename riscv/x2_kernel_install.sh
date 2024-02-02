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

# カーネルインストール
apt install -y linux-{image,headers}-riscv64 initramfs-tools

# !!!注:キーボード設定[keyboard-configuration]はqemuでキーボードを適切に渡す必要がある

# 日付、言語の設定用
apt install -y tzdata locales

# 日付、言語の設定
dpkg-reconfigure tzdata
dpkg-reconfigure locales

# u-bootインストール
apt install -y u-boot-menu

# u-bootの設定
