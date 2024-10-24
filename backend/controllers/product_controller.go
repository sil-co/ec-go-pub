// controllers/product_controller.go
package controllers

import (
	"context"
	"encoding/json"
	"net/http"

	// "github.com/gorilla/mux"
	"ec-api/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var productCollection *mongo.Collection // MongoDBのコレクション

func InitProductController(collection *mongo.Collection) {
	productCollection = collection
}

// products
func GetProducts(w http.ResponseWriter, r *http.Request) {
	var products []models.Product                                   // 製品のスライスを作成
	cursor, err := productCollection.Find(context.TODO(), bson.D{}) // すべての製品を取得
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO()) // 関数終了時にカーソルをクローズ

	for cursor.Next(context.TODO()) { // カーソルを使用して製品を反復処理
		var product models.Product
		if err := cursor.Decode(&product); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		products = append(products, product) // 製品をスライスに追加
	}

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(products) // JSON形式で製品のリストをエンコードして返す
}

func GetProductsByUser(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("userId") // クエリパラメータからユーザーIDを取得
	var products []models.Product

	cursor, err := productCollection.Find(context.TODO(), bson.M{"userId": userID})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO())

	for cursor.Next(context.TODO()) {
		var product models.Product
		if err := cursor.Decode(&product); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		products = append(products, product) // スライスに追加
	}

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(products) // JSON形式で製品のリストを返す
}

// /product
func GetProduct(w http.ResponseWriter, r *http.Request) {
	productID := r.URL.Query().Get("id") // クエリパラメータから製品IDを取得
	var product models.Product

	// 製品IDをObjectIDに変換
	id, err := primitive.ObjectIDFromHex(productID)
	if err != nil {
		http.Error(w, "Invalid product ID", http.StatusBadRequest)
		return
	}

	err = productCollection.FindOne(context.TODO(), bson.M{"_id": id}).Decode(&product) // 製品IDで検索
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	json.NewEncoder(w).Encode(product) // JSON形式で製品情報を返す
}

func AddToProduct(w http.ResponseWriter, r *http.Request) {
	// AuthorizationヘッダーからJWTトークンを取得
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Missing token", http.StatusUnauthorized)
		return
	}

	claims, err := ValidateJWT(tokenString)
	userID := claims.UserID
	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	var product models.Product
	err = json.NewDecoder(r.Body).Decode(&product)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// 受け取ったuserIDをProductに追加
	product.UserID = userID

	_, err = productCollection.InsertOne(context.TODO(), product)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}
