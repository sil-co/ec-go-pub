## 実行手順
バックエンド。フロントエンドは「ECGo/frontend」フォルダのreadmeを参照
- VSCodeを開いてない場合、ECGoフォルダをルートプロジェクトとして、VSCodeで開く
- `ctrl + j`でターミナルを開く、または既にターミナルを開いている場合は、「+」ボタンで新しくターミナルを作成する
- `cd ./backend`で `backend`ディレクトリに移動
### Docker起動
- DockerでDBを起動するので、Docker-desktopのインストールが必要。(Linuxはdocker-composeのインストール)
- Docker desktopを起動
- `docker-compose up -d`でdockerコンテナを起動
### Go起動
- `go mod tidy`で依存関係の解決
- `go run ./main.go`でgoを起動
