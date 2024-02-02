#!/bin/bash -ex

# 初期ディスクの作成

_DIR=$(cd $(dirname $0) ; pwd)
source "$_DIR/com/com.sh"
export_env "$_DIR"

is_file "$_BUSYBOX_PATH"

# 初期化用ディスクの作成とフォーマット
if [[ -e "$_INIT_DISK_PATH" ]];then
    sudo rm "$_INIT_DISK_PATH"
fi
dd if=/dev/zero of="$_INIT_DISK_PATH" bs=32M count=1
sudo mkfs.ext4 "$_INIT_DISK_PATH"

# 初期化用ディスクのループバックマウント
tmp_mnt="$_DIR/disk/tmp_mnt"
sudo rm -R "$tmp_mnt" || true;mkdir -p "$tmp_mnt"
sudo mount "$_INIT_DISK_PATH" "$tmp_mnt"

# 起動用のファイル構成作成
sudo mkdir -p "$tmp_mnt"/{bin,sbin,dev,etc,home,mnt,proc,sys,usr,tmp}
sudo mkdir -p "$tmp_mnt"/usr/{bin,sbin}
sudo mkdir -p "$tmp_mnt"/proc/sys/kernel
(cd "$tmp_mnt"/dev;sudo mknod sda b 8 0)
(cd "$tmp_mnt"/dev;sudo mknod console c 5 1)

# busyboxの設置とinit処理の作成
sudo cp "$_BUSYBOX_PATH" "$tmp_mnt/bin/busybox"
cat "$_DIR/x0_init.sh" | sudo sh -c "cat > $tmp_mnt/init"
sudo chmod +x "$tmp_mnt/bin/busybox"
sudo chmod +x "$tmp_mnt/init"

# debootのシェルの設置
deb_sh="$tmp_mnt/home/x1_debootstrap.sh"
sudo cp "$_DIR/x1_debootstrap.sh" "$deb_sh"
sudo chmod +x "$deb_sh"

# ------------ debootのシェルにUUID情報を追加 ------------
# ループバックデバイス設定
loopback=`set_device "$_DISK_PATH"`

# パーティションIDの取得
boot_partid=`name_to_partid "$loopback" 'boot'`
root_partid=`name_to_partid "$loopback" 'root'`
swap_partid=`name_to_partid "$loopback" 'swap'`

# パーティション毎のデバイスを取得
boot_dev=`sudo findfs PARTUUID="$boot_partid"`
root_dev=`sudo findfs PARTUUID="$root_partid"`
swap_dev=
if [[ "$swap_partid" != 'no' ]]; then
    swap_dev=`sudo findfs PARTUUID="$swap_partid"`
fi

# パーティションのUUIDを取得
boot_uuid=`get_uuid_by_device "$boot_dev"`
root_uuid=`get_uuid_by_device "$root_dev"`
swap_uuid=
if [[ "$swap_partid" != 'no' ]]; then
    swap_uuid=`get_uuid_by_device "$swap_dev"`
fi

# uuid情報書き込み
sudo sed -i -E 's#^(boot_uuid)=.*$#\1='$boot_uuid'#g' "$deb_sh"
sudo sed -i -E 's#^(root_uuid)=.*$#\1='$root_uuid'#g' "$deb_sh"
if [[ "$swap_partid" != 'no' ]]; then
    sudo sed -i -E 's#^(swap_uuid)=.*$#\1='$swap_uuid'#g' "$deb_sh"
fi

sleep 3

# ループバックデバイス解除
unset_device "$_DISK_PATH"

# -----------------------------------------------------

sleep 3

sudo umount "$tmp_mnt"
