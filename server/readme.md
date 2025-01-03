## bashスクリプトで構築
- [外部サービス]VPSサーバー構築: Kagoya想定
- ssh接続のための設定
    <!-- - [ローカルPC上]SSHフォルダを作成: `mkdir -p ~/.ssh` ➔ 基本ある -->
    <!-- - [ローカルPC上]`.ssh`権限変更: `chmod 700 ~/.ssh` ➔ 基本700 -->
    - [ローカルPC上]`for_vps`ファイルを作成: `vim ~/.ssh/for_vps`
    - [ローカルPC上]`server/.env`内の`$SSH_PRIVATE_KEY`をコピーして貼り付け保存
    - [ローカルPC上]`~/.ssh/for_vps`の権限変更: `chmod 600 ~/.ssh/for_vps`
- [ローカルPC上]`ec-app/server/scripts/deploy.sh`の`server_name`の値を該当のIPアドレスに変更する
- [ローカルPC上]ssh login: `ssh your_user@your_server_ip -i ~/.ssh/for_vps`
- [ローカルPC上]`ec-app/frontend/lib/utils/config.dart`を本番環境用のIPに変更しプッシュ
- [リモートサーバー上]スクリプトファイル作成: `vim ~/deploy.sh`
- [リモートサーバー上]中身は`scripts/deploy.sh`をコピーし貼り付け
- [リモートサーバー上]権限追加: `chmod +x deploy.sh`
- [リモートサーバー上]実行: `./deploy.sh`

---

<!-- 下記は実現が手間なので、bashスクリプトを用いる -->
## ansible実行手順
※windows10を使用している場合
- wsl(ubuntu)がない場合、インストールする: `wsl --install -d ubuntu`を実行しインストール
- wsl内に入る: `wsl -d ubuntu`
- `sudo apt update`
- `sudo apt upgrade`
- `sudo apt install ansible`