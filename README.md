# QEMU_test
qemuのテスト

# 説明
- 最初に`sudo apt-get install qemu-system`でqemuをインストールする必要がある
- wsl2上からはubuntu22.0.4のisoはカーネルパニックが発生して起動できなかった

# その他まとめ

- [isoでの起動について書いてある](https://qiita.com/momoto/items/b7e2a2b28f91c4cb5cec)

- [kernelのビルドから行っている](https://zenn.dev/kaishuu0123/articles/bfdeedc0492483281a4c)

- [qemu-imgオプションについて丁寧に書いてある](https://manual.geeko.jp/ja/cha.qemu.guest_inst.html)

- [qemu-system-*のオプションについて丁寧に書いてある](https://www15.big.or.jp/~yamamori/sun/qemu/usage.html)

- ddコマンドについて
    - [リンク](http://earth.sci.ehime-u.ac.jp/~kameyama/linuxtips.html)
    - ddはディスクイメージを作成できる
    - またディスクイメージはマウントできる
    - `dd if=/dev/zero of=test.img bs=1G count=4`で4Gのからディスクイメージ作成
    - `sudo mkfs.ext4 test.img`でフォーマット
    - `mount test.img /mnt`でマウント

- ループバックデバイス(=ループバックマウント)について
    - [リンク](https://elsammit-beginnerblg.hatenablog.com/entry/2021/01/31/123737)
    - ディスクイメージをデバイスのように扱う仮想のデバイス
    - `/dev/loop*`が対応する
    - `losetup --all`使用済みロープバックデバイスの確認
    - `sudo losetup /dev/loop0 test.img`で`/dev/loop0`に`test.img`を紐づけ
    - `sudo mount -t ext4 /dev/loop0 /mnt`通常のマウント
    - `sudo losetup -d /dev/loop0`で紐づけ解除
    - [複数パーティションのデバイスイメージのマウント](https://takuya-1st.hatenablog.jp/entry/2014/12/12/202139)

- qemu-imgのrawについて
    - [リンク](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-using_qemu_img-supported_qemu_img_formats)
    - 基本的にrawはディスクイメージを指定する
    - なので`dd if=/dev/zero of=test.img bs=1k count=4 ; mkfs.ext4 test.img`をした場合には
    - `sudo qemu-img -f raw test.img -O qcow2 new.qcow2`ができる

