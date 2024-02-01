#!/bin/bash -ex

# メインディスクの作成

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

if [[ "$1" != 'disk_create=no' ]] || [[ ! -e "$_DISK_PATH" ]]; then
    dd if=/dev/zero of="$_DISK_PATH" bs=512M count=15

    loopback=`set_device "$_DISK_PATH"`

    # パーティション分け
    set_partion "$loopback" '200M' '2G' '4G' '1G'

fi

loopback=`set_device "$_DISK_PATH"`

# フォーマット
set_format "$_DISK_PATH"

# パーティションIDの取得
efi_partid=`name_to_partid "$_DISK_PATH" 'efi'`
boot_partid=`name_to_partid "$_DISK_PATH" 'boot'`
root_partid=`name_to_partid "$_DISK_PATH" 'root'`
swap_partid=`name_to_partid "$_DISK_PATH" 'swap'`

# パーティション毎のデバイスを取得
efi_dev=`sudo findfs PARTUUID="$efi_partid"`
boot_dev=`sudo findfs PARTUUID="$boot_partid"`
root_dev=`sudo findfs PARTUUID="$root_partid"`
swap_dev=
if [[ "$swap_partid" != 'no' ]]; then
    swap_dev=`sudo findfs PARTUUID="$swap_partid"`
fi

efi_uuid=`get_uuid_by_device "$efi_dev"`
boot_uuid=`get_uuid_by_device "$boot_dev"`
root_uuid=`get_uuid_by_device "$root_dev"`
swap_uuid=
if [[ "$swap_partid" != 'no' ]]; then
    swap_uuid=`get_uuid_by_device "$swap_dev"`
fi

tmp_mnt="$_DIR/disk/tmp_mnt"
mkdir -p "$tmp_mnt"

deb_sh="$_DIR/disk/x1_debootstrap.sh"
sudo cp "$_DIR/x1_debootstrap.sh" "$deb_sh"
sudo chmod +x "$deb_sh"

sed -i -E 's#^(efi_uuid)=.*$#\1='$efi_uuid'#g' "$deb_sh"
sed -i -E 's#^(boot_uuid)=.*$#\1='$boot_uuid'#g' "$deb_sh"
sed -i -E 's#^(root_uuid)=.*$#\1='$root_uuid'#g' "$deb_sh"
if [[ "$swap_partid" != 'no' ]]; then
    sed -i -E 's#^(swap_uuid)=.*$#\1='$swap_uuid'#g' "$deb_sh"
fi

# マウント(sys,proc,devは除外)
sudo mkdir -p "$tmp_mnt"
sudo mount -t ext4 "$root_dev" "$tmp_mnt"
sudo mkdir -p "$tmp_mnt/boot"
sudo mount -t ext4 "$boot_dev" "$tmp_mnt/boot"
sudo mkdir -p "$tmp_mnt/boot/efi"
sudo mount -t vfat "$efi_dev" "$tmp_mnt/boot/efi"

# ディスクの準備
sudo debootstrap \
    --arch riscv64 --foreign \
    --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
    --include=debian-archive-keyring,curl,vim \
    sid "$tmp_mnt" \
    'http://deb.debian.org/debian/'

# テスト
#[Invalid Release file, no entry for main/binary-riscv64/Packages]
#sudo ./disk/x2_umount.sh /home/yutaishikawa/work/QEMU_test/riscv/disk/tmp_mnt
#tmp_path='/home/yutaishikawa/work/QEMU_test/riscv/disk/test_deboot';mkdir -p "$tmp_path";sudo rm -R "$tmp_path";mkdir -p "$tmp_path"
#sudo debootstrap --arch riscv64 --foreign \
#    --keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg \
#    --include=debian-ports-archive-keyring sid \
#    "$tmp_path" http://deb.debian.org/debian-ports
#tmp_path='/home/yutaishikawa/work/QEMU_test/riscv/disk/test_deboot';mkdir -p "$tmp_path";sudo rm -R "$tmp_path";mkdir -p "$tmp_path"
#sudo debootstrap \
#    --arch riscv64 --foreign \
#    jammy \
#    "$tmp_path" http://de.archive.ubuntu.com/ubuntu

sleep 3

# アンマウント
umount_all "$tmp_mnt"

# ディスクの解除
unset_device "$_DISK_PATH"
