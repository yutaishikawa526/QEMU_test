#!/bin/bash -ex

# 設定ファイルのサンプル
# このファイルの項目を変更し、同じディレクトリに「conf.sh」として指定する
# 未作成の場合はこのファイルが使用される

# qemuで使用するメモリサイズ(MD)
_QEMU_MEMORY=2048

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
