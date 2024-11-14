package controllers

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"ec-api/models"

	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var productCollection *mongo.Collection // MongoDBのコレクション

func InitProductController(collection *mongo.Collection) {
	productCollection = collection
}

// products
func GetProductsAll(w http.ResponseWriter, r *http.Request) {
	var products []models.Product
	options := options.Find().SetSort(bson.D{
		{Key: "createdat", Value: -1},
	})
	cursor, err := productCollection.Find(context.TODO(), bson.D{}, options)
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
	// AuthorizationヘッダーからJWTトークンを取得
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Missing token", http.StatusUnauthorized)
		return
	}

	// JWTトークンを検証し、userIDを取得
	claims, err := ValidateJWT(tokenString)
	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}
	userID := claims.UserID

	var products []models.Product
	options := options.Find().SetSort(bson.D{
		{Key: "createdat", Value: -1},
	})
	// userIDに基づいて製品を取得するクエリを作成
	cursor, err := productCollection.Find(context.TODO(), bson.M{"userID": userID}, options)
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

	// 現在の日時をCreatedAtに設定
	product.CreatedAt = primitive.NewDateTimeFromTime(time.Now())

	_, err = productCollection.InsertOne(context.TODO(), product)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func UpdateProduct(w http.ResponseWriter, r *http.Request) {
	// JWTトークンの検証
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

	// URLパラメータからProductIdを取得
	params := mux.Vars(r)
	productID, err := primitive.ObjectIDFromHex(params["ProductId"])
	if err != nil {
		http.Error(w, "Invalid product ID", http.StatusBadRequest)
		return
	}

	// リクエストボディから更新するプロダクト情報を取得
	var product models.Product
	err = json.NewDecoder(r.Body).Decode(&product)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// UserIDを除外した更新内容を作成
	updateFields := bson.M{}
	if product.Name != "" {
		updateFields["name"] = product.Name
	}
	if product.Description != "" {
		updateFields["description"] = product.Description
	}
	if product.Price != 0 { // Assuming Price is a float or int
		updateFields["price"] = product.Price
	}
	if product.Stock != 0 {
		updateFields["stock"] = product.Stock
	}
	if product.Category != "" {
		updateFields["category"] = product.Category
	}

	if len(updateFields) == 0 {
		http.Error(w, "No fields to update", http.StatusBadRequest)
		return
	}

	// 該当のプロダクトを更新
	filter := bson.M{"_id": productID, "userID": userID}
	// update := bson.M{"$set": product}
	// result, err := productCollection.UpdateOne(context.TODO(), filter, update)
	update := bson.M{"$set": updateFields}
	result, err := productCollection.UpdateOne(context.TODO(), filter, update)
	if err != nil || result.MatchedCount == 0 {
		http.Error(w, "Product not found or unauthorized", http.StatusNotFound)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func DeleteProduct(w http.ResponseWriter, r *http.Request) {
	// JWTトークンの検証
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

	// URLパラメータからProductIdを取得
	params := mux.Vars(r)
	productID, err := primitive.ObjectIDFromHex(params["ProductId"])
	if err != nil {
		http.Error(w, "Invalid product ID", http.StatusBadRequest)
		return
	}

	// 該当のプロダクトを削除
	filter := bson.M{"_id": productID, "userID": userID}
	result, err := productCollection.DeleteOne(context.TODO(), filter)
	if err != nil || result.DeletedCount == 0 {
		http.Error(w, "Product not found or unauthorized", http.StatusNotFound)
		return
	}

	w.WriteHeader(http.StatusOK)
}
