#!/bin/bash

# 初回以降

_QCOW2_PATH=`pwd`/disk_iso/CentOS.qcow2

../common.sh

exec_boot "$_QCOW2_PATH"
