#!/bin/bash

# 更新と必要なパッケージのインストール
echo "Updating system and installing required packages..."
sudo apt update
sudo apt install -y docker.io docker-compose git nginx unzip

# Flutterのインストール
if ! command -v flutter &> /dev/null
then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
    flutter --version
else
    echo "Flutter is already installed."
    source ~/.bashrc
fi

# Goのインストール
if ! command -v go &> /dev/null
then
    echo "Installing Go..."
    wget https://go.dev/dl/go1.23.3.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.23.3.linux-amd64.tar.gz
    export PATH="$PATH:/usr/local/go/bin"
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
    source ~/.bashrc
    rm go1.23.3.linux-amd64.tar.gz

else
    echo "Go is already installed."
fi

# GitHubリポジトリをクローンまたは更新
echo "Cloning or updating the GitHub repository..."
if [ -d "/var/www/html/ec-go-pub" ]; then
    echo "Project directory already exists. Pulling latest changes..."
    cd /var/www/html/ec-go-pub
    git config --global core.autocrlf true
    git config core.fileMode false
    git config --global --add safe.directory /var/www/html/ec-go-pub
    GIT_SSH_COMMAND="ssh -i ~/.ssh/for_vps" git pull
    cd /var/www/html/ec-go-pub/backend
else
    GIT_SSH_COMMAND="ssh -i ~/.ssh/for_vps" git clone git@github.com:sil-co/ec-go-pub.git /var/www/html/ec-go-pub
    cd /var/www/html/ec-go-pub/backend
fi

# Docker Composeを使ってアプリケーションを起動
echo "Starting Docker Compose..."
docker-compose up -d

# Goアプリケーションのビルドと実行
echo "Building Go application..."
cd /var/www/html/ec-go-pub/backend
go get
go mod tidy
go build -o app main.go

echo "Starting Go application..."
nohup ./app &
echo "Go is running..."

# Flutterウェブアプリのビルド
echo "Building Flutter web application..."
cd /var/www/html/ec-go-pub/frontend
flutter pub get
flutter build web

# ビルド済みFlutterファイルをNginxのルートディレクトリにコピー
echo "Deploying Flutter web application to Nginx..."

# Nginx設定ファイルを作成
echo "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/flutter_site <<EOL
server {
    listen 80;
    server_name your_domain_or_ip;

    root /var/www/html/ec-go-pub/frontend/build/web;
    index index.html index.htm;

    # フロントエンドへのリクエスト
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Goサーバーへのリバースプロキシ
    location /api/ {
        rewrite ^/api/?(.*)$ /$1 break;
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOL

# Nginxの権限を修正
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Nginx設定を有効にしてリロード
sudo ln -sf /etc/nginx/sites-available/flutter_site /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# Firewall設定
sudo apt install ufw
yes | sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw status verbose

echo "Deployment completed. You can now access your Flutter site at http://your_domain_or_ip"
