# create disk image

# 説明
diskイメージを作成してその上にubuntuをインストール後に起動する形式
別のリポジトリ用のコードを流用する

# 設定
- [UbuntuSettings用の設定ファイルのサンプル](./conf/conf_UbuntuSettings-sample.sh)を適切に記載する。
    - この内容はそのままUbuntuSettingsの設定ファイルとして使用する
    - ファイル名は`conf_UbuntuSettings.sh`で保存する

# 手順
- `0_initialize.sh`で初期化を行う
- `1_create_disk.sh`でディスクイメージの作成を行う
- `2_exec_boot.sh`で実行する
- 以降は`2_exec_boot.sh`のみで実行できる
