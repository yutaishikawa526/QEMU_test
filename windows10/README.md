# windows10の起動

## 手順
1. [サイト](https://www.microsoft.com/ja-jp/software-download/windows10ISO)からwindows10用のインストールメディア(ISO)をダウンロード
2. [サイト](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/)からwindows用のvirtioのインストールメディア(ISO)をダウンロード
3. [disk](./disk/)に1,2でダウンロードしたISOファイルを設置
    - 1でダウンロードしたものはファイル名を`Win10_XXX_lang_x64.iso`とする
    - 2でダウンロードしたものはファイル名を`virtio-win-XXX.iso`とする
4. [0_initialize.sh](./0_initialize.sh)を実行してディスク作成とインストール
    - インストール時に、最初にディスクが認識されていないため、ドライブのインストールを実施する
    - 上記インストール後、ディスクが認識されてwindows10のインストールが可能となる
    - windowsのローカルアカウント作成にはメールアドレスを`no@thankyou.com`と入力
5. [1_exec.sh](./1_exec.sh)でwindows10起動

## その他
- [イヤホンを利用する](https://ww2.coastal.edu/mmurphy2/oer/qemu/audio/)
- [参考サイト](https://ktaka.blog.ccmp.jp/2023/03/kvmqemuwindows.html)

