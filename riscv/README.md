# riscvのlinuxカーネルコンパイル

# 説明
diskイメージを作成してその上にubuntuをインストール後に起動する形式
別のリポジトリ用のコードを流用する

# 設定
- [ディスク用の設定ファイルのサンプル](./conf/conf_part-sample.sh)を適切に記載する。
    - 作成するディスクイメージの設定ファイルとして使用する
    - ファイル名は`conf_part.sh`で保存する

# 手順
- `0_initialize.sh`で初期化を行う
- `1_create_disk.sh`でディスクイメージの作成を行う
- `2_exec_boot.sh`で実行する
- 以降は`2_exec_boot.sh`のみで実行できる

# 参考サイト
- [32bit RISC-V Linuxを作りQEMUで実行する](https://blog.rogiken.org/blog/2023/04/06/32bit-risc-v-linux%E3%82%92%E4%BD%9C%E3%82%8Aqemu%E3%81%A7%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8B/)
- [Linux on RISC-V using QEMU and BUSYBOX from scratch](https://risc-v-machines.readthedocs.io/en/latest/linux/simple/)
- [Booting RISC-V on QEMU](https://jborza.com/post/2021-04-03-running-riscv-qemu/)
- [Running 64- and 32-bit RISC-V Linux on QEMU](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html)
