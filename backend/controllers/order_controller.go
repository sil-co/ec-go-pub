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
	"go.mongodb.org/mongo-driver/mongo/options"
)

type OrderWithProducts struct {
	ID        primitive.ObjectID `json:"id"`
	UserID    primitive.ObjectID `json:"userID"`
	Products  []OrderProductInfo `json:"products"`
	Total     float64            `json:"totalAmount"`
	Status    string             `json:"status"`
	OrderedAt primitive.DateTime `json:"orderedAt"`
}

type OrderProductInfo struct {
	ProductID primitive.ObjectID `json:"productID"`
	Quantity  int                `json:"quantity"`
	Product   ProductInfo        `json:"product"` // 商品情報を追加
}

type ProductInfo struct {
	ID          primitive.ObjectID `json:"id"`
	Name        string             `json:"name"`
	Description string             `json:"description"`
	Price       float64            `json:"price"`
	Stock       int                `json:"stock"`
}

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

	options := options.Find().SetSort(bson.D{
		{Key: "orderedat", Value: -1},
	})
	// ユーザーIDに基づいて注文を取得
	cursor, err := orderCollection.Find(context.TODO(), bson.M{"userID": userID}, options)
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

		// 注文データを直接追加
		orders = append(orders, order)
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
	// AuthorizationヘッダーからJWTトークンを取得
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Missing token", http.StatusUnauthorized)
		return
	}

	// トークンを検証
	claims, err := ValidateJWT(tokenString)
	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}
	userID := claims.UserID

	// リクエストボディのデコード
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

	// 注文をデータベースに追加
	_, err = orderCollection.InsertOne(context.TODO(), order)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated) // 注文追加の成功レスポンス
}
