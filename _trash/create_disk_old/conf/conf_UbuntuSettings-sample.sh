#!/bin/bash -e

# 設定ファイル

# 使用しないため変更の必要はない
_DISK_DIR="$_DIR"/disk
_EFI_FNAME='efi.img'
_ROOT_FNAME='root.img'

# 自動で書き換えるため、変更の必要はない
# efiディスクのパス
_DISK_EFI=
# rootディスクのパス
_DISK_ROOT=

# ディスクのマウントポイント
# すでにマウントポイントになっている場所は注意
_MNT_DIR="/mnt"

# 変更禁止
_COM_DIR="$_DIR/com"

# debianのディストリビューションの名前
_DEB_NAME=jammy

# debootstrapのときのオプション
_DEB_OPTION='--arch amd64 --variant minbase'
# debootstrapの対象のアーキテクチャ
_DEBOOT_TARGET=amd64

# カーネルのバージョン
_KERNEL_VER='5.15.0-25'

# その他で追加でインストールするパッケージ
_KERNEL_OTHER_INSTALL=''

# イーサネットのインターフェース名
# [ip a]コマンドで確認する
_NW_INTERFACE=enp0s25

# [grub-install]で指定するターゲット
_GRUB_TARGET=x86_64-efi

# [grub-efi-*]パッケージの名前
_GRUB_EFI_PACKAGE=grub-efi-amd64

# 使用しないため変更の必要はない
_ROOT_DSIZE=12