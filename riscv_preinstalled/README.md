# riscv&preinstalledイメージ

## 説明
- 公式が配布しているUbuntuのpreinstalledイメージをriscv上で起動

## 手順
- [設定ファイルのサンプル](./conf/conf-sample.sh)`conf-sample.sh`を参考に`conf.sh`ファイルを作成
- [0_initialize.sh](./0_initialize.sh)で初期化
- [1_exec_preinst.sh](./1_exec_preinst.sh)でインストール済みメディアを起動
- [2_exec_live_installer.sh](./2_exec_live_installer.sh)でLiveインストーラーの起動
- [3_exec_live_installed.sh](./3_exec_live_installed.sh)で`2_exec_live_installer.sh`でインストールしたディスクの起動

## 参考サイト
- [公式のpreinstalledイメージ配布](https://ubuntu.com/download/risc-v)
- [公式の起動手順](https://wiki.ubuntu.com/RISC-V/QEMU)

## その他
- 普通にubuntu riscvの[ミラーサイト](http://ports.ubuntu.com/ubuntu-ports/dists/jammy/)があった…
