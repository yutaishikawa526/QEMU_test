#!/bin/bash -ex

# 実験用に作成
# debootstrapのみ実行したディスクを作成する

# diskイメージの作成とフォーマット
# ループバックデバイス登録、debootstrapまで行う

START_POINT=1

echo '----------------------- start -----------------------'

_DISK_DIR=$(cd $(dirname $0) ; pwd)/disk/test
_DISK_FILE_PATH="$_DISK_DIR"/disk.img
_MOUNT_DIR="$_DISK_DIR"/mnt

# 必要なパッケージの追加
# arch-install-scriptsはarch-chrootをするためのパッケージ
if [ "$START_POINT" -le 0 ]; then
    add-apt-repository universe
    apt update && apt install -y debootstrap arch-install-scripts
fi

# ディスク作成
if [ "$START_POINT" -le 1 ]; then
    # umount
    ! mountpoint -q "$_MOUNT_DIR"/boot/efi || sudo umount "$_MOUNT_DIR"/boot/efi
    ! mountpoint -q "$_MOUNT_DIR" || sudo umount "$_MOUNT_DIR"

    # ループバックデバイス解除
    losetup | grep "$_DISK_FILE_PATH" \
    | sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
    | xargs -I loop_num sudo kpartx -d "loop_num"

    losetup | grep "$_DISK_FILE_PATH" \
    | sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
    | xargs -I loop_num sudo losetup -d "loop_num"

    sudo rm -R "$_DISK_DIR"
    mkdir "$_DISK_DIR"
    mkdir "$_MOUNT_DIR"

    dd if=/dev/zero of="$_DISK_FILE_PATH" bs=1G count=15
    sudo gdisk "$_DISK_FILE_PATH"

    sudo partprobe

    sudo kpartx "$_DISK_FILE_PATH" -a
fi

# パーティションの探索
_EFI_PART=''
_ROOT_PART=''
while read device_name ; do
    if [[ "$device_name" =~ EFI\ System ]]; then
        _EFI_PART=`echo "$device_name" | sed -r 's#^/dev(/loop[0-9]+p[0-9]+).*$#/dev/mapper\1#'`
    fi
    if [[ "$device_name" =~ Linux\ filesystem ]]; then
        _ROOT_PART=`echo "$device_name" | sed -r 's#^/dev(/loop[0-9]+p[0-9]+).*$#/dev/mapper\1#'`
    fi
done << END
`sudo losetup | grep "$_DISK_FILE_PATH" | sed -r 's#^(/dev/loop[0-9]+).*$#\1#' | xargs sudo fdisk -l | grep -E '^/dev/loop[0-9]+p[0-9]+'`
END

if [[ "$_EFI_PART" =~ ^$ ]]; then
    echo 'efiパーティションが見つかりません'
    exit
fi
if [[ "$_ROOT_PART" =~ ^$ ]]; then
    echo 'rootパーティションが見つかりません'
    exit
fi

# パーティション設定
if [ "$START_POINT" -le 2 ]; then
    # パーティションのフォーマット
    sudo mkfs.vfat "$_EFI_PART"
    sudo mkfs.ext4 "$_ROOT_PART"
fi

# マウント済みならumount
while read mount_str ; do
    cmd=`echo "$mount_str" | sed -r 's#^[^ ]+ on ([^ ]+) .*$#sudo umount \1 #' `
    eval "$cmd"
done << END
`sudo mount | grep -E "^($_EFI_PART|$_ROOT_PART) on $_MOUNT_DIR(/boot/efi)? " | tac`
END

# マウント
sudo mount "$_ROOT_PART" "$_MOUNT_DIR"
sudo mkdir -p "$_MOUNT_DIR"/boot/efi
sudo mount "$_EFI_PART" "$_MOUNT_DIR"/boot/efi

# debootstrapでの最小構成の設置
sudo debootstrap jammy "$_MOUNT_DIR" http://de.archive.ubuntu.com/ubuntu

# fstabの設定
sudo genfstab -U "$_MOUNT_DIR" | sudo sh -c "cat >> $_MOUNT_DIR/etc/fstab"

# aptのミラーサイト設定
{
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy           main restricted universe'
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy-security  main restricted universe'
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy-updates   main restricted universe'
} | sudo sh -c "cat > $_MOUNT_DIR/etc/apt/sources.list"

# umount
sudo umount "$_MOUNT_DIR"/boot/efi
sudo umount "$_MOUNT_DIR"

# ループバックデバイス解除
losetup | grep "$_DISK_FILE_PATH" \
| sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
| xargs -I loop_num sudo kpartx -d "loop_num"

losetup | grep "$_DISK_FILE_PATH" \
| sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
| xargs -I loop_num sudo losetup -d "loop_num"

echo '----------------------- fin -----------------------------'
