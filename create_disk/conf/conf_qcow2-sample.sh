#!/bin/bash -e

# 作成するディスク側の設定ファイル
# 適切に編集し、[conf_qcow2.sh]という名前で保存する

# 作成されるディスクのフルパス
_QCOW2_PATH="$_DIR/disk/disk.qcow2"

# ディスクサイズ(G|M)
# 最初の512Mはefi用、残りをroot用として使用する。
_QCOW2_SIZE=12G

# nbdで使用する使用可能な仮想ディスク
_NBD_DISK=/dev/nbd0
