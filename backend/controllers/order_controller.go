// controllers/order_controller.go
package controllers

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"ec-api/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var orderCollection *mongo.Collection // MongoDBのコレクション

func InitOrderController(collection *mongo.Collection) {
	orderCollection = collection
}

// orders
func GetOrders(w http.ResponseWriter, r *http.Request) {
	// AuthorizationヘッダーからJWTトークンを取得
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Missing token", http.StatusUnauthorized)
		return
	}

	claims, err := ValidateJWT(tokenString)
	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	userID := claims.UserID

	var orders []models.Order

	// ユーザーIDに基づいて注文を取得
	cursor, err := orderCollection.Find(context.TODO(), bson.M{"userID": userID})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO())

	for cursor.Next(context.TODO()) {
		var order models.Order
		if err := cursor.Decode(&order); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		orders = append(orders, order) // 注文をスライスに追加
	}

	orderJSON, err := json.MarshalIndent(orders, "", "  ") // インデント付きでJSONに変換
	if err != nil {
		log.Fatalf("Failed to marshal order: %v", err)
	}
	fmt.Println(string(orderJSON), userID)

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// 注文のリストをJSON形式で返す
	json.NewEncoder(w).Encode(orders)
}

// order
func AddToOrder(w http.ResponseWriter, r *http.Request) {
	// AuthorizationヘッダーからJWTトークンを取得
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Missing token", http.StatusUnauthorized)
		return
	}

	claims, err := ValidateJWT(tokenString)
	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	userID := claims.UserID

	var order models.Order
	err = json.NewDecoder(r.Body).Decode(&order)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// 注文に新しいIDを生成
	order.ID = primitive.NewObjectID()
	order.UserID = userID

	// 現在の日時を設定
	order.OrderedAt = primitive.NewDateTimeFromTime(time.Now())

	orderJSON, err := json.MarshalIndent(order, "", "  ") // インデント付きでJSONに変換
	if err != nil {
		log.Fatalf("Failed to marshal order: %v", err)
	}
	fmt.Println(string(orderJSON)) // JSON文字列を表示

	// 注文をデータベースに追加
	_, err = orderCollection.InsertOne(context.TODO(), order)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated) // 注文追加の成功レスポンス
}
