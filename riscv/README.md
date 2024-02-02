# riscvのlinuxカーネルコンパイル

## 説明
- qemu上でdebianを動かす
- インストールはdebootstrapを使用する
- 最終的には「openSBI + U-boot」で起動可能なイメージファイルを作成するのが目的
- 最終的な成果物について
    - `./disk/opensbi_uboot`が「openSBI + U-boot」のブートローダー
        - ただし、QEMU専用となっている
        - 実デバイス等で使用したい場合は[3_opensbi_compile.sh](./3_opensbi_compile.sh)の`# ubootのコンパイル`の`qemu-riscv64_smode_defconfi`を適切に修正する必要がある
    - `./disk/img.raw`がgpt形式の`./disk/opensbi_uboot`で起動可能なdebianのデバイス
- インストール手順の概要
    1. debootstrap
        - 最終的なメインイメージファイルを用意
        - メインイメージをパーティション&フォーマットし、debootstrapのfirst stage(--foreign)を実行
        - riscv用のlinuxカーネルとopenSBI1(u-bootをpayloadしない)とopenSBI2(u-bootをpayloadする)とbusyboxをコンパイル
        - riscv用の初期rootイメージを作成。このときinitでbusyboxのshが起動するように指定
        - biosをopenSBI1、カーネルをコンパイルしたlinuxカーネル、rootデバイスを初期rootイメージを指定してqemu起動
        - 初期rootイメージからメインイメージをmount&chrootし、debootstrapのsecond stageを実行
    2. kernelインストール
        - biosをopenSBI1、カーネルをコンパイルしたlinuxカーネル、rootデバイスをメインイメージのrootパーティションに指定してqemu起動
        - aptでlinux-image,headers,initramfs,u-bootをインストール
        - u-bootの起動設定を行う
    3. 完了
        - biosをopenSBI2、メインイメージをデバイスに設定しqemu起動
        - 「openSBI + U-boot」とメインイメージのu-boot設定でdebian起動

## 手順
1. [設定ファイルのサンプル](./conf/conf-sample.sh)を参考に同ディレクトリに`conf.sh`ファイルを作成
2. [0_initialize.sh](./0_initialize.sh)を実行
3. [1_kernel_compile.sh](./1_kernel_compile.sh)を実行
    - 途中でコンパイル設定の画面が表示される
    - 特に変更しなくても実行可能
4. [2_busybox_compile.sh](./2_busybox_compile.sh)を実行
    - 途中でコンパイル設定の画面が表示されるが、`Settings` -> `Build options` にある `Build static binary` を`yes`にする
5. [3_opensbi_compile.sh](./3_opensbi_compile.sh)を実行
6. [4_create_maindisk.sh](./4_create_maindisk.sh)を実行
7. [5_setup_maindisk.sh](./5_setup_maindisk.sh)を実行
8. [6_create_initdisk.sh](./6_create_initdisk.sh)を実行
9. [7_exec_debootstrap.sh](./7_exec_debootstrap.sh)を実行
    - 実行後、ゲストPCでlinuxが起動し、serial接続の画面が表示される
    - 画面上に`exec command '/home/x1_debootstrap.sh'`と表示されたら、`/home/x1_debootstrap.sh`を実行する
    - 途中でroot権限のパスワードを求められるため入力する
    - 完了後、`poweroff -f`を実行して終了する
10. [8_kernel_install.sh](./8_kernel_install.sh)を実行
    - 実行後、serial接続の画面が表示される
    - root権限でログインする
    - rootのホームディレクトリに`2x_kernel_install.sh`が設置されているため、実行する
    - 途中で日付と言語の設定画面が表示されるため設定する
    - 完了後、`shutdown -h now`を実行して終了する
11. 完了
    - 以降は[9_exe.sh](./9_exe.sh)で実行可能
    - 起動の初期段階で起動するカーネルを選択する画面が表示されるため選択する
    - 終了は`shutdown -h now`で行う
12. 途中で失敗した場合
    - [10_clear.sh](./10_clear.sh)を実行することでマウント状態やループバックデバイスを閉じることができる
    - `sudo ps -av`で実行中のタスクを確認して`kill`することを検討する
    - エラーの内容によっては途中からのやりなしも検討

## その他
- Ubuntuはriscv用のパッケージがないため、debootstrapその他でのインストールができない
    - ただし公式サイトがUbuntuをインストール済みの[イメージファイルを配布](https://ubuntu.com/download/risc-v)している

## 参考サイト
- [32bit RISC-V Linuxを作りQEMUで実行する](https://blog.rogiken.org/blog/2023/04/06/32bit-risc-v-linux%E3%82%92%E4%BD%9C%E3%82%8Aqemu%E3%81%A7%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8B/)
- [Linux on RISC-V using QEMU and BUSYBOX from scratch](https://risc-v-machines.readthedocs.io/en/latest/linux/simple/)
- [Booting RISC-V on QEMU](https://jborza.com/post/2021-04-03-running-riscv-qemu/)
- [Running 64- and 32-bit RISC-V Linux on QEMU](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html)
- [qemu-riscv64-static + chroot + debootstrapでriscv環境を動作させる](https://cstmize.hatenablog.jp/entry/2020/01/25/qemu-riscv64-static_%2B_chroot_%2B_debootstrap%E3%81%A7riscv%E7%92%B0%E5%A2%83%E3%81%AE%E3%83%90%E3%82%A4%E3%83%8A%E3%83%AA%E3%82%92%E5%8B%95%E3%81%8B%E3%81%99)
- [RISC-V Debian Rootfs from scratch](https://github.com/carlosedp/riscv-bringup/blob/master/Debian-Rootfs-Guide.md)
- [wiki debian org RISC-V](https://wiki.debian.org/RISC-V)
- [QEMU RISC-V openSBI Compile](https://github.com/riscv-software-src/opensbi/blob/v1.3/docs/platform/qemu_virt.md)
- [qemu-system-riscv64でubuntuをbootさせられなかった（失敗編）](https://qiita.com/rizkubo/items/5ac1f70addc5aad2d500)
- [RISC-VのDebianイメージをQEMUで動かす](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0603)
- [Booting Linux from U-Boot in qemu-system-riscv64?](https://groups.google.com/a/groups.riscv.org/g/sw-dev/c/Xdv14d8J-n4/m/sQvE6W5KCAAJ)
