#!/bin/bash -e

# カーネルコンパイル

_DIR=$(cd $(dirname $0) ; pwd)
_LINUX_SRC="$_DIR/clone/linux"
_BUSYBOX_SRC="$_DIR/clone/busyBox"

(cd "$_LINUX_SRC";make ARCH=riscv CROSS_COMPILE=gcc-riscv64-linux-gnu- defconfig)
(cd "$_LINUX_SRC";make ARCH=riscv CROSS_COMPILE=gcc-riscv64-linux-gnu- -j $(nproc))

#
# 作りかけ
#
