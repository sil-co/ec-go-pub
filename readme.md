# 簡易版EC Webアプリ

このプロジェクトは、**Go**, **Flutter**, **MongoDB** を使用して構築した簡易版EC Webアプリです。  
決済機能は含まれておらず、商品を登録・閲覧するだけの基本的な機能を提供しています。学習目的で作成しました。

---

## 主な技術スタック

- **フロントエンド**: Flutter（Web対応）
- **バックエンド**: Go
- **データベース**: MongoDB
- **インフラ**: Docker（MongoDBのコンテナ化）

---

## 機能

1. **商品登録**
   - 商品名、価格、説明、画像などの情報を登録可能。
   - 入力フォームはFlutterで構築。
2. **商品閲覧**
   - 登録された商品の一覧を表示。
   - 商品詳細ページで詳細情報を確認可能。

---

## プロジェクト構成

```
project/
├── backend/             # Go (バックエンド)
│   ├── main.go          # サーバーのエントリーポイント
│   ├── handlers/        # HTTPハンドラ
│   ├── models/          # データベースモデル
│   └── docker-compose.yml   # MongoDBコンテナの設定
├── frontend/            # Flutter (フロントエンド)
│   ├── lib/
│   │   ├── main.dart    # Flutterエントリーポイント
│   │   ├── pages/       # ページコンポーネント
│   │   └── widgets/     # 再利用可能なウィジェット
└── README.md            # プロジェクト説明
```

---

## セットアップと実行方法

### 1. 前提条件

- [Go](https://golang.org/) インストール済み
- [Flutter](https://flutter.dev/) インストール済み
- [Docker](https://www.docker.com/) インストール済み

### 2. データベースの起動

```bash
cd backend/
docker-compose up -d
```

### 3. バックエンドの起動

```bash
go run main.go
```

サーバーは `http://localhost:8080` で起動します。

### 4. フロントエンドの起動

```bash
cd frontend/
flutter run -d chrome
```

アプリはブラウザで `http://localhost:8080` を通じてアクセスできます。

---

## APIエンドポイント

| メソッド | エンドポイント        | 説明             |
| -------- | --------------------- | ---------------- |
| `POST`   | `/products`           | 新しい商品を登録 |
| `GET`    | `/products`           | 商品一覧を取得   |
| `GET`    | `/products/:id`       | 特定の商品取得   |

---

## 学習ポイント

- **Go** を使用した RESTful API の構築方法
- **Flutter** を使用したレスポンシブな Web フロントエンドの作成
- **MongoDB** を用いたデータ管理とクエリの基礎
- Docker を活用した簡易的な開発環境構築

---

## 今後の改善予定

- デザインの改善
- ユーザー認証機能の追加
- 検索およびフィルタリング機能の実装
- 決済機能の導入

---

## ライセンス

このプロジェクトは学習目的で作成しました。
商用利用は想定していません。

---

## 開発者
[Shelner]   
[X](https://x.com/shelnerX) | 
[Youtube](https://www.youtube.com/@shelpro) | 
[Zenn](https://zenn.dev/shelpro) | 
