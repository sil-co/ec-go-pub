package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"ec-api/models"
)

var client *mongo.Client

// MongoDB接続設定
func connectMongoDB() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var err error
	client, err = mongo.Connect(ctx, options.Client().ApplyURI("mongodb://admin:thepassofmongo@localhost:27017"))
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("MongoDB connected!")
}

// ユーザー登録ハンドラ
func createUser(w http.ResponseWriter, r *http.Request) {
	var user models.User
	_ = json.NewDecoder(r.Body).Decode(&user)
	user.ID = primitive.NewObjectID()
	user.CreatedAt = primitive.NewDateTimeFromTime(time.Now())

	collection := client.Database("ec-db").Collection("users")
	_, err := collection.InsertOne(context.TODO(), user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	fmt.Printf("User created! Name: %s\n", user.Username)
	json.NewEncoder(w).Encode(user)
}

// ユーザー一覧取得ハンドラ
func getUsers(w http.ResponseWriter, r *http.Request) {
	collection := client.Database("ec-db").Collection("users")
	cursor, err := collection.Find(context.TODO(), bson.M{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO())

	var users []models.User
	for cursor.Next(context.TODO()) {
		var user models.User
		cursor.Decode(&user)
		users = append(users, user)
	}
	json.NewEncoder(w).Encode(users)
}

// 商品一覧取得ハンドラ
func getProducts(w http.ResponseWriter, r *http.Request) {
	collection := client.Database("ec-db").Collection("products")
	cursor, err := collection.Find(context.TODO(), bson.M{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO())

	var products []models.Product
	for cursor.Next(context.TODO()) {
		var product models.Product
		cursor.Decode(&product)
		products = append(products, product)
	}
	json.NewEncoder(w).Encode(products)
}

// 注文作成ハンドラ
func createOrder(w http.ResponseWriter, r *http.Request) {
	var order models.Order
	_ = json.NewDecoder(r.Body).Decode(&order)
	order.ID = primitive.NewObjectID()
	order.OrderedAt = primitive.NewDateTimeFromTime(time.Now())

	collection := client.Database("ec-db").Collection("orders")
	_, err := collection.InsertOne(context.TODO(), order)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(order)
}

// cross origin許可
func enableCORS(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// OPTIONSリクエストへの対応
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		h.ServeHTTP(w, r)
	})
}

func main() {
	getEcDB()
	connectMongoDB()
	r := mux.NewRouter()

	// ルート設定 RESTfull設計
	// users
	r.HandleFunc("/users", getUsers).Methods("GET")

	// user
	// r.HandleFunc("/user", getUser).Methods("GET")
	r.HandleFunc("/user", createUser).Methods("POST")
	// r.HandleFunc("/user", updateUser).Methods("PUT")
	// r.HandleFunc("/user", deleteUser).Methods("DELETE")

	// products
	r.HandleFunc("/products", getProducts).Methods("GET")

	// product
	// r.HandleFunc("/product", getProduct).Methods("GET")
	// r.HandleFunc("/product", createProduct).Methods("POST")
	// r.HandleFunc("/product", updateProduct).Methods("PUT")
	// r.HandleFunc("/product", deleteProduct).Methods("DELETE")

	// orders
	// r.HandleFunc("/orders", getOrders).Methods("GET")
	// r.HandleFunc("/orders", createOrders).Methods("POST")
	// r.HandleFunc("/orders", updateOrders).Methods("PUT")
	// r.HandleFunc("/orders", deleteOrders).Methods("DELETE")

	// order
	// r.HandleFunc("/order", getOrder).Methods("GET")
	r.HandleFunc("/order", createOrder).Methods("POST")
	// r.HandleFunc("/order", updateOrder).Methods("PUT")
	// r.HandleFunc("/order", deleteOrder).Methods("DELETE")

	fmt.Println("Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", enableCORS(r)))
}

func getEcDB() {
	// MongoDBに接続
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI("mongodb://admin:thepassofmongo@localhost:27017"))
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err := client.Disconnect(ctx); err != nil {
			log.Fatal(err)
		}
	}()

	// データベース取得
	database := client.Database("ec-db")

	// 現在のディレクトリからパスを組み立てる
	saveDir, err := filepath.Abs("./resources/backup/ecdb")
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
		if err := exportCollectionToJSON(ctx, database, collectionName, saveDir); err != nil {
			log.Fatalf("Failed to export collection %s: %v", collectionName, err)
		}
	}

	fmt.Println("すべてのコレクションのデータをJSONファイルに保存しました。")
}

// コレクションのデータをJSON形式でファイルに保存する関数
func exportCollectionToJSON(ctx context.Context, db *mongo.Database, collectionName string, saveDir string) error {
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
