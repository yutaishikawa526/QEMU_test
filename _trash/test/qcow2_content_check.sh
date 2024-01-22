#!/bin/bash -e

# qcow2のディスクを中身を適切に変えてからconvertしたときの中身を確認

_EXCE_DIR=$(cd $(dirname $0) ; pwd)
_MOUNT_1="$_EXCE_DIR/disk/mnt1"
_MOUNT_2="$_EXCE_DIR/disk/mnt2"

if [[ "$1" == 'create=yes' ]]; then
    source "$_EXCE_DIR/qcow2_drive.sh"
    exit
fi
set --
source "$_EXCE_DIR/qcow2_drive.sh"

bash "$_EXCE_DIR/qcow2_drive.sh" create=yes

bash "$_EXCE_DIR/qcow2_drive.sh" format=yes

# ------------ 追加の処理 ------------
loopback=`create_loopback "$_TMP_IMG_PATH"`

disk1="/dev/mapper/$loopback"p1
disk2="/dev/mapper/$loopback"p2

sudo mkdir -p "$_MOUNT_1"
sudo mkdir -p "$_MOUNT_2"
sudo umount "$_MOUNT_1" || true
sudo umount "$_MOUNT_2" || true

sudo mount "$disk1" "$_MOUNT_1"
sudo mount "$disk2" "$_MOUNT_2"

sudo touch "$_MOUNT_1"/test1.txt
sudo touch "$_MOUNT_1"/test2.txt

echo 'test1' | sudo sh -c "cat > '$_MOUNT_1/test1.txt'"
echo 'test2' | sudo sh -c "cat > '$_MOUNT_2/test2.txt'"

sudo umount "$_MOUNT_1"
sudo umount "$_MOUNT_2"

remove_loopback "$_TMP_IMG_PATH"
# -----------------------------------

bash "$_EXCE_DIR/qcow2_drive.sh" convert=yes

bash "$_EXCE_DIR/qcow2_drive.sh" exe2=yes

