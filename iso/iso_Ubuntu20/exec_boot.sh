#!/bin/bash -e

# 初回以降

_EXCE_DIR=$(cd $(dirname $0) ; pwd)

_QCOW2_PATH="$_EXCE_DIR"/disk_iso/ubuntuOS.qcow2

source "$_EXCE_DIR"/../common.sh

exec_boot "$_QCOW2_PATH"
