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
    source ~/.bashrc
    flutter --version
else
    echo "Flutter is already installed."
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
if [ -d "/var/www/html/ec-app" ]; then
    echo "Project directory already exists. Pulling latest changes..."
    cd /var/www/html/ec-app
    git config --global core.autocrlf true
    git config core.fileMode false
    git config --global --add safe.directory /var/www/html/ec-app
    GIT_SSH_COMMAND="ssh -i ~/.ssh/for_vps" git pull
    cd /var/www/html/ec-app/backend
else
    GIT_SSH_COMMAND="ssh -i ~/.ssh/for_vps" git clone git@github.com:shelner/ec-app.git /var/www/html/ec-app
    cd /var/www/html/ec-app/backend
fi

# Docker Composeを使ってアプリケーションを起動
echo "Starting Docker Compose..."
docker-compose up -d

# Goアプリケーションのビルドと実行
echo "Building Go application..."
cd /var/www/html/ec-app/backend
go get
go mod tidy
go build -o app main.go

echo "Starting Go application..."
nohup ./app &
echo "Go is running..."

# Flutterウェブアプリのビルド
echo "Building Flutter web application..."
cd /var/www/html/ec-app/frontend
flutter pub get
flutter build web

# ビルド済みFlutterファイルをNginxのルートディレクトリにコピー
echo "Deploying Flutter web application to Nginx..."

# Nginx設定ファイルを作成
echo "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/flutter_site <<EOL
server {
    listen 80;
    server_name 133.18.232.127;

    root /var/www/html/ec-app/frontend/build/web;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOL

# Nginxの権限を修正
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Nginx設定を有効にしてリロード
sudo ln -sf /etc/nginx/sites-available/flutter_site /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

echo "Deployment completed. You can now access your Flutter site at http://your_domain_or_ip"
