# riscvのlinuxカーネルコンパイル

# 説明
- linuxカーネルとbusyboxをriscv用にコンパイル
- busyboxを使用してinitramfsを作成
- qemuで実行
- 予めディスクイメージに`debootstrap --foreign`でubuntuのパッケージを設置
- qemuで実行後、最初に`debootstrap --second-stage`により解凍
- chrootし、必要なモジュールをインストール

# 参考サイト
- [32bit RISC-V Linuxを作りQEMUで実行する](https://blog.rogiken.org/blog/2023/04/06/32bit-risc-v-linux%E3%82%92%E4%BD%9C%E3%82%8Aqemu%E3%81%A7%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8B/)
- [Linux on RISC-V using QEMU and BUSYBOX from scratch](https://risc-v-machines.readthedocs.io/en/latest/linux/simple/)
- [Booting RISC-V on QEMU](https://jborza.com/post/2021-04-03-running-riscv-qemu/)
- [Running 64- and 32-bit RISC-V Linux on QEMU](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html)
- [qemu-riscv64-static + chroot + debootstrapでriscv環境を動作させる](https://cstmize.hatenablog.jp/entry/2020/01/25/qemu-riscv64-static_%2B_chroot_%2B_debootstrap%E3%81%A7riscv%E7%92%B0%E5%A2%83%E3%81%AE%E3%83%90%E3%82%A4%E3%83%8A%E3%83%AA%E3%82%92%E5%8B%95%E3%81%8B%E3%81%99)
