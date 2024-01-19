#!/bin/bash -e

# 初回時
# isoダウンロードからディスクイメージ作成、起動まで

_EXCE_DIR=$(cd $(dirname $0) ; pwd)

_ISO_PATH="$_EXCE_DIR"/disk_iso/CentOS.iso
_QCOW2_PATH="$_EXCE_DIR"/disk_iso/CentOS.qcow2
_ISO_URL='https://ftp.jaist.ac.jp/pub/Linux/CentOS-vault/6.4/isos/x86_64/CentOS-6.4-x86_64-minimal.iso'

source "$_EXCE_DIR"/../common.sh

initial_install "$_ISO_PATH" "$_QCOW2_PATH" "$_ISO_URL"
