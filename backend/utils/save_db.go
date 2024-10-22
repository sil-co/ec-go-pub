package utils

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func SaveCollections() {
	// MongoDBに接続
	ConnectMongoDB()

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client := GetMongoClient()
	defer func() {
		if err := client.Disconnect(ctx); err != nil {
			log.Fatal(err)
		}
	}()

	// データベース取得
	database := client.Database("ec-db")

	currentDate := time.Now().Format("2006-01-02")

	// 現在のディレクトリからパスを組み立てる
	saveDir, err := filepath.Abs(filepath.Join("./resources/backup/ecdb", currentDate))
	if err != nil {
		log.Fatalf("パスの解決に失敗しました: %v", err)
	}

	// ディレクトリが存在しない場合は作成
	if err := os.MkdirAll(saveDir, 0755); err != nil {
		log.Fatalf("Failed to create directory %s: %v", saveDir, err)
	}

	// データベース内のコレクション一覧を取得
	collections, err := database.ListCollectionNames(ctx, bson.M{})
	if err != nil {
		log.Fatal(err)
	}

	// 各コレクションのデータをJSON形式で保存
	for _, collectionName := range collections {
		if err := ExportCollectionToJSON(ctx, database, collectionName, saveDir); err != nil {
			log.Fatalf("Failed to export collection %s: %v", collectionName, err)
		}
	}

	fmt.Println("すべてのコレクションのデータをJSONファイルに保存しました。")
}

// コレクションのデータをJSON形式でファイルに保存する関数
func ExportCollectionToJSON(ctx context.Context, db *mongo.Database, collectionName string, saveDir string) error {
	collection := db.Collection(collectionName)

	// 全ドキュメント取得
	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		return err
	}
	defer cursor.Close(ctx)

	var documents []bson.M
	if err = cursor.All(ctx, &documents); err != nil {
		return err
	}

	// JSON形式に変換
	data, err := json.MarshalIndent(documents, "", "  ")
	if err != nil {
		return err
	}

	fileName := fmt.Sprintf("%s.json", collectionName)
	filePath := filepath.Join(saveDir, fileName)

	// JSONファイルに保存
	if err := os.WriteFile(filePath, data, 0644); err != nil {
		return err
	}

	fmt.Printf("コレクション %s を %s に保存しました。\n", collectionName, fileName)
	return nil
}
