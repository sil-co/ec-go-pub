// controllers/order_controller.go
package controllers

import (
	"context"
	"encoding/json"
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
	userID := r.URL.Query().Get("userId") // クエリパラメータからユーザーIDを取得
	var orders []models.Order

	// ユーザーIDに基づいて注文を取得
	cursor, err := orderCollection.Find(context.TODO(), bson.M{"userId": userID})
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

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// 注文のリストをJSON形式で返す
	json.NewEncoder(w).Encode(orders)
}

// order
func AddToOrder(w http.ResponseWriter, r *http.Request) {
	var order models.Order
	err := json.NewDecoder(r.Body).Decode(&order)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// 注文に新しいIDを生成
	order.ID = primitive.NewObjectID()

	// ユーザーIDが空でないことを確認
	if order.UserID.IsZero() {
		http.Error(w, "userId is required", http.StatusBadRequest)
		return
	}

	// 現在の日時を設定
	order.OrderedAt = primitive.NewDateTimeFromTime(time.Now())

	// 注文をデータベースに追加
	_, err = orderCollection.InsertOne(context.TODO(), order)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated) // 注文追加の成功レスポンス
}
