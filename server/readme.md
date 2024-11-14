## bashスクリプトで構築
- ssh login: `ssh your_user@your_server_ip`
- shファイル作成: `vim ~/deploy.sh`
    - 中身は`scripts/deploy.sh`をコピーし貼り付け
    - 権限追加: `chmod +x deploy.sh`
- 実行前 ssh設定が必要
    - SSHフォルダを作成: `mkdir -p ~/.ssh`
    - 権限変更: `chmod 700 ~/.ssh`
    - `for_vps`ファイルを作成: `vim ~/.ssh/for_vps`
    - `server/.env`内の`SSH_PRIVATE_KEY`をコピーして貼り付け
    - 権限変更: `chmod 600 ~/.ssh/for_vps`
- 実行: `./deploy.sh`








---

## ansible実行手順(実現が手間なので、bashスクリプトを用いる)
※windows10を使用している場合
- wsl(ubuntu)がない場合、インストールする: `wsl --install -d ubuntu`を実行しインストール
- wsl内に入る: `wsl -d ubuntu`
- `sudo apt update`
- `sudo apt upgrade`
- `sudo apt install ansible`