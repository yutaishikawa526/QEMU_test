#!/bin/bash

# 初回時
# isoダウンロードからディスクイメージ作成、起動まで

_ISO_PATH=`pwd`/disk_iso/ubuntuOS.iso
_QCOW2_PATH=`pwd`/disk_iso/ubuntuOS.qcow2
_ISO_URL='https://old-releases.ubuntu.com/releases/20.04.4/ubuntu-20.04-beta-desktop-amd64.iso'

../common.sh

initial_install "$_ISO_PATH" "$_QCOW2_PATH" "$_ISO_URL"
