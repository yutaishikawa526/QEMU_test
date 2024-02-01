#!/bin/busybox sh

# debootstrapのsecond stageを実行
# riscv上で実行される

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

echo '--------- start mount ---------'

# マウント
mount -t ext4 "$root_dev" "$mnt_point"
mount -t ext4 "$boot_dev" "$mnt_point/boot"
# !!!注 [-t vfat]を指定するとマウントに失敗する
# カーネルにvfatのmoduleが組み込まれていない
mount "$efi_dev" "$mnt_point/boot/efi"
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

echo '--------- modify resolv.conf ---------'

# resolv.confの修正
{
    echo '[network]';
    echo 'nameserver 8.8.8.8';
} > "$mnt_point/etc/resolv.conf"

echo '--------- set date and time ---------'

# 日付の設定
nowdate=`date +'%Y/%m/%d %H:%M:%S'`
chroot "$mnt_point" date --set="$nowdate"

echo '--------- set fstab ---------'

# fstabの設定
# !!!注:efiパーティションは最初はvfatがマウントできないためコメントアウトする
# マウントできるようになったらコメントアウト[#--efi_mark--]を削除する
{
    echo '# root'
    echo "UUID=$root_uuid / ext4 defaults 0 1"
    echo '# boot'
    echo "UUID=$boot_uuid /boot ext4 defaults 0 2"
    echo '# efi'
    echo "#--efi_mark--UUID=$efi_uuid /boot/efi vfat defaults 0 2"
    if [ ! $swap_uuid = '' ]; then
        echo '# swap'
        echo "UUID=$swap_uuid none swap defaults 0 0"
    fi
} > "$mnt_point/etc/fstab"

echo '--------- set mirror url ---------'

# aptのミラーサイト設定
{
    echo 'deb http://deb.debian.org/debian/ sid main'
    echo 'deb http://deb.debian.org/debian/ unstable main'
    echo 'deb http://deb.debian.org/debian/ experimental main'
} > "$mnt_point/etc/apt/sources.list"

echo '--------- setup systemd-networkd ---------'

# networkdの起動設定
chroot "$mnt_point" systemctl enable systemd.networkd
{
    echo ''
    echo '[Match]'
    echo 'Name=eth0'
    echo ''
    echo '[Network]'
    echo 'DHCP=yes'
    echo ''
} > "$mnt_point/etc/systemd/network/ethernet.network"
