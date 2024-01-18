#!/bin/bash

# ループバックデバイス解除

RAW_DISK_PATH=`pwd`/disk/ubuntu_disk_raw.img

losetup | grep "$RAW_DISK_PATH" \
| sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
| xargs -I loop_num sudo kpartx -d "loop_num"

losetup | grep "$RAW_DISK_PATH" \
| sed -r 's/^.*(\/dev\/loop[0-9]+).*$/\1/' \
| xargs -I loop_num sudo losetup -d "loop_num"

