#!/bin/bash

# 初回以降

_QCOW2_PATH=`pwd`/disk_iso/CentOS.qcow2

qemu-system-x86_64 "$_QCOW2_PATH" \
 -enable-kvm -cpu host -m 1024
