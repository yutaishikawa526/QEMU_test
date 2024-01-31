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

efi_partid=`name_to_partid "$_DISK_PATH" 'efi'`
boot_partid=`name_to_partid "$_DISK_PATH" 'boot'`
root_partid=`name_to_partid "$_DISK_PATH" 'root'`
swap_partid=`name_to_partid "$_DISK_PATH" 'swap'`

efi_dev=`sudo findfs PARTUUID="$efi_partid"`
boot_dev=`sudo findfs PARTUUID="$boot_partid"`
root_dev=`sudo findfs PARTUUID="$root_partid"`
swap_dev=`sudo findfs PARTUUID="$swap_partid"`

total_device_uuid=`get_uuid_by_device "$loopback" 'PTUUID'`
efi_uuid=`get_uuid_by_device "$efi_dev"`
boot_uuid=`get_uuid_by_device "$boot_dev"`
root_uuid=`get_uuid_by_device "$root_dev"`
swap_uuid=`get_uuid_by_device "$swap_dev"`

tmp_mnt="$_DIR/disk/tmp_mnt"
mkdir -p "$tmp_mnt"

tmp_sh1="$_DIR/disk/x1_mount_by_uuid.sh"
sudo cp "$_DIR/x1_mount_by_uuid.sh" "$tmp_sh1"
tmp_sh2="$_DIR/disk/x2_umount.sh"
sudo cp "$_DIR/x2_umount.sh" "$tmp_sh2"
tmp_sh3="$_DIR/disk/x3_debootstrap.sh"
sudo cp "$_DIR/x3_debootstrap.sh" "$tmp_sh3"
tmp_sh4="$_DIR/disk/x4_chroot_install.sh"
sudo cp "$_DIR/x4_chroot_install.sh" "$tmp_sh4"
tmp_sh5="$_DIR/disk/x5_main.sh"
sudo cp "$_DIR/x5_main.sh" "$tmp_sh5"

sudo chmod +x "$tmp_sh1"
sudo chmod +x "$tmp_sh2"
sudo chmod +x "$tmp_sh3"
sudo chmod +x "$tmp_sh4"
sudo chmod +x "$tmp_sh5"

sed -i -E 's#^(efi_uuid)=.*$#\1='$efi_uuid'#g' "$tmp_sh1"
sed -i -E 's#^(boot_uuid)=.*$#\1='$boot_uuid'#g' "$tmp_sh1"
sed -i -E 's#^(root_uuid)=.*$#\1='$root_uuid'#g' "$tmp_sh1"

sed -i -E 's#^(efi_uuid)=.*$#\1='$efi_uuid'#g' "$tmp_sh3"
sed -i -E 's#^(boot_uuid)=.*$#\1='$boot_uuid'#g' "$tmp_sh3"
sed -i -E 's#^(root_uuid)=.*$#\1='$root_uuid'#g' "$tmp_sh3"
sed -i -E 's#^(swap_uuid)=.*$#\1='$swap_uuid'#g' "$tmp_sh3"

sed -i -E 's#^(total_device_uuid)=.*$#\1='$total_device_uuid'#g' "$tmp_sh4"

sudo sh "$tmp_sh1" "$tmp_mnt"

# ディスクの準備
sudo debootstrap --arch riscv64 --foreign --include=debian-archive-keyring,wget,curl,vim sid "$tmp_mnt" 'http://deb.debian.org/debian/' || echo 'failer'

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

sudo sh "$tmp_sh2" "$tmp_mnt"

# ディスクの解除
unset_device "$_DISK_PATH"
