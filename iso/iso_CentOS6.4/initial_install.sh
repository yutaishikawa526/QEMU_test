#!/bin/bash

# 初回時
# isoダウンロードからディスクイメージ作成、起動まで

_ISO_PATH=`pwd`/disk_iso/CentOS.iso
_QCOW2_PATH=`pwd`/disk_iso/CentOS.qcow2
_ISO_URL='https://ftp.jaist.ac.jp/pub/Linux/CentOS-vault/6.4/isos/x86_64/CentOS-6.4-x86_64-minimal.iso'

../common.sh

initial_install "$_ISO_PATH" "$_QCOW2_PATH" "$_ISO_URL"
