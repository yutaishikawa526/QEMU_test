#!/bin/bash -e

# qemuでの立ち上げ後、ゲストPC側で実行するべきシェル

# ネットワーク設定の再作成
echo 'インターネット接続に使用するネットの名前を選択してください。'
echo '候補'
ip a \
    | grep -E '^[1-9][0-9]*: [a-zA-Z0-9]+: ' \
    | sed -r 's#^[1-9][0-9]*: ([a-zA-Z0-9]+): .*$#\1#g'
read -p net_name
sed -i 's#^Name=.*$#Name='$net_name'#g' '/etc/systemd/network/ethernet.network'

systemctl restart systemd-networkd

# grubの更新
grub-install
update-grub
