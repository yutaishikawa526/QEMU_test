
# マウント処理
# ゲストPCとホストPCの両方で実行される

efi_uuid=
boot_uuid=
root_uuid=

mnt_point=$1
if [ "$mnt_point" = '' ]; then
    mnt_point='/mnt'
fi

root_dev=`blkid | grep "$root_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`
boot_dev=`blkid | grep "$boot_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`
efi_dev=`blkid | grep "$efi_uuid" | head -n 1 | sed -r 's#^(/dev/[^:]+): .*$#\1#g'`
mkdir -p "$mnt_point"
mount -t ext4 "$root_dev" "$mnt_point"
mkdir -p "$mnt_point/boot"
mount -t ext4 "$boot_dev" "$mnt_point/boot"
mkdir -p "$mnt_point/boot/efi"
mount "$efi_dev" "$mnt_point/boot/efi"
mkdir -p "$mnt_point/dev"
mkdir -p "$mnt_point/sys"
mkdir -p "$mnt_point/proc"
mount --bind /dev "$mnt_point/dev"
mount --bind /sys "$mnt_point/sys"
mount --bind /proc "$mnt_point/proc"
