#!/bin/bash -e

# 初回時
# isoダウンロードからディスクイメージ作成、起動まで

_EXCE_DIR=$(cd $(dirname $0) ; pwd)

_ISO_PATH="$_EXCE_DIR"/disk_iso/ubuntuOS.iso
_QCOW2_PATH="$_EXCE_DIR"/disk_iso/ubuntuOS.qcow2
_ISO_URL='https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso'

source "$_EXCE_DIR"/../common.sh

initial_install "$_ISO_PATH" "$_QCOW2_PATH" "$_ISO_URL"
