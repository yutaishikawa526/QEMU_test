#!/bin/bash -e

# 必要なgit repositoryの設置

_DIR=$(cd $(dirname $0) ; pwd)
_CLONE_DIR="$_DIR/clone/UbuntuSettings"
_CREATE_DIR="$_CLONE_DIR"

sudo apt update
sudo apt install -y git qemu-kvm qemu-utils

# 必要ならば
# sudo apt install -y libvirt-daemon bridge-utils virt-manager

# 必要なリポジトリのダウンロード
sudo rm -R "$_CLONE_DIR" || true
git clone https://github.com/yutaishikawa526/Ubuntu_install "$_CLONE_DIR"
sudo rm -R "$_CLONE_DIR/.git"

sudo mkdir -p "$_DIR/disk/mnt"

# 設定ファイルの設置
{
    echo '#!/bin/bash -e'
    echo '_DISK_BASE='
    echo "_MNT_POINT='$_DIR/disk/mnt'"
    echo "_DISK_IMG_PATH='$_DIR/disk/img.raw'"
    echo '_DEB_NAME=jammy'
    echo "_DEB_OPTION='--arch amd64 --variant minbase'"
    echo "_KERNEL_VER='5.15.0-25'"
    echo '_KERNEL_OTHER_INSTALL='
    echo "_GRUB_TARGET='i386-pc'"
    echo '_GRUB_EFI_PACKAGE="grub-pc grub-pc-bin"'
    echo '_APT_SOURCE_LIST=$(cat << EOF'
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy           main restricted universe'
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy-security  main restricted universe'
    echo 'deb http://de.archive.ubuntu.com/ubuntu jammy-updates   main restricted universe'
    echo 'EOF'
    echo ')'
} | sudo sh -c "cat > $_CREATE_DIR/conf/conf.sh"

{
    echo '#!/bin/bash -e'
    echo '_PAT_EFI='
    echo '_PAT_BOOT='
    echo '_PAT_ROOT='
    echo '_PAT_SWAP='
} | sudo sh -c "cat > $_CREATE_DIR/conf/conf_mnt.sh"

if [ ! -e "$_DIR/conf/conf_part.sh" ]; then
    echo 'UbuntuSettings用の設定ファイルがありません。'
    exit 1
fi
sudo cp "$_DIR/conf/conf_part.sh" "$_CREATE_DIR/conf/conf_part.sh"

sudo chmod 744 -R "$_CREATE_DIR"
