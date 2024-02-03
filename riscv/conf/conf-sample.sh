#!/bin/bash -ex

# 設定ファイルのサンプル
# このファイルの項目を変更し、同じディレクトリに[conf.sh]として指定する
# 未作成の場合はこのファイルが使用される
# また[conf.sh]で未指定の項目はこのファイルの設定が適用される
# [$top_dir]には[../](riscvディレクトリのフルパス)が指定される

# linuxカーネルのソースコードのcloneディレクトリ
_LINUX_SRC="$top_dir/clone/linux"
# busyboxのソースコードのcloneディレクトリ
_BUSYBOX_SRC="$top_dir/clone/busyBox"
# openSBIのソースコードのcloneディレクトリ
_OPENSBI_SRC="$top_dir/clone/opensbi"
# U-bootのソースコードのcloneディレクトリ
_UBOOT_SRC="$top_dir/clone/uboot"

# コンパイル後のlinuxカーネルバイナリへのフルパス
_KERNEL_PATH="$top_dir/disk/kernelImage"
# コンパイル後のbusyboxバイナリへのフルパス
_BUSYBOX_PATH="$top_dir/disk/busybox"
# コンパイル後のopenSBIバイナリ(U-bootのpayloadなし)へのフルパス
_OPENSBI_PATH="$top_dir/disk/opensbi"
# コンパイル後のopenSBIバイナリ(U-bootのpayloadあり)へのフルパス
_OPENSBI_UBOOT_PATH="$top_dir/disk/opensbi_uboot"

# debootstrap実行用のルートファイルシステムのイメージディスクへのフルパス
_INIT_DISK_PATH="$top_dir/disk/init_disk.raw"
# メインディスクへのフルパス
_DISK_PATH="$top_dir/disk/img.raw"

# qemuで使用するメモリサイズ(MD)
_QEMU_MEMORY=2048
# qemuで使用するcpuの数
_QEMU_SMP=1

# メインイメージのサイズ
# 「512MB * $_DISK_TOTAL_SIZE」で計算する
# 数字で指定(例は8.5GB)
_DISK_TOTAL_SIZE='17'

# rootパーティション(/)のサイズ
# 「4G」「500M」で指定(例は2GB)
_DISK_ROOT_SIZE='2G'

# bootパーティション(/boot)のサイズ
# 「4G」「500M」で指定(例は4GB)
_DISK_BOOT_SIZE='4G'

# swapパーティションのサイズ
# 「4G」「500M」で指定(例は2GB)
# 未入力の場合は作成しない
_DISK_SWAP_SIZE='2G'

# インストールするカーネルイメージ
_KERNEL_IMG_PKG='linux-image-riscv64'
# インストールするカーネルヘッダー
_KERNEL_HEADERS_PKG='linux-headers-riscv64'
# インストールするinitramfs
_INITRAMFS_PKG='initramfs-tools'
## Ubuntuのサンプル
## [6_kernel_install.sh]の中でdebootstrap後に[chroot /mnt apt install linux-{image,headers}]を実行すると適当なものを教えてくれる
#_KERNEL_IMG_PKG='linux-image-5.15.0-1028-generic'
#_KERNEL_HEADERS_PKG='linux-headers-5.15.0-1028-generic'
#_INITRAMFS_PKG='initramfs-tools'
