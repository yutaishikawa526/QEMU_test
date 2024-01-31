
# アンマウント処理
# ゲストPCとホストPCの両方で実行される

mnt_point=$1
if [ "$mnt_point" = '' ]; then
    mnt_point='/mnt'
fi

umount "$mnt_point/dev"
umount "$mnt_point/sys"
umount "$mnt_point/proc"
umount "$mnt_point/boot/efi"
umount "$mnt_point/boot"
umount "$mnt_point"
