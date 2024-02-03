#!/bin/bash -ex

# debootstrapの実行に関する設定ファイル
# このファイルの項目を変更し、同じディレクトリに[conf_debootstrap.sh]として指定する
# 未作成の場合はこのファイルが使用される
# また[conf.sh]で未指定の項目はこのファイルの設定が適用される

# debootstrap時のgpg鍵へのフルパス
# [no]と指定すると[--no-check-gpg]が指定される
# 空文字の場合は何も指定しない(デフォルトが使用される)
_DEBSTRAP_KEYRING='/usr/share/keyrings/debian-archive-keyring.gpg'

# debootstrap時の[--include]に指定される値
# Comma separated list of packages which will be added to download and extract lists.
_DEBSTRAP_INCLUDE='debian-archive-keyring,curl,vim'

# ディストリビューションのコードネームかシンボリックリンク
# The SUITE may be a release code name (eg, sid, stretch, jessie) or a symbolic name (eg, unstable, testing, stable, oldstable)
_DEBSTRAP_SUITE='sid'

# debootstrapする対象のミラーサイト
_DEBSTRAP_URL='http://deb.debian.org/debian/'

##ubuntuのサンプル
#_DEBSTRAP_KEYRING='/usr/share/keyrings/ubuntu-archive-keyring.gpg'
#_DEBSTRAP_INCLUDE='ubuntu-keyring,curl,vim'
#_DEBSTRAP_SUITE='jammy'
#_DEBSTRAP_URL='http://ports.ubuntu.com/ubuntu-ports/'
