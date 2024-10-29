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

	var orders []OrderWithProducts

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

		// プロダクト情報を取得するためのスライス
		var productsInfo []OrderProductInfo

		for _, orderProduct := range order.Products {
			var product models.Product // Productモデルを定義していると仮定
			err := productCollection.FindOne(context.TODO(), bson.M{"_id": orderProduct.ProductID}).Decode(&product)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			// プロダクト情報を構築
			productsInfo = append(productsInfo, OrderProductInfo{
				ProductID: orderProduct.ProductID,
				Quantity:  orderProduct.Quantity,
				Product: ProductInfo{
					ID:          product.ID,
					Name:        product.Name,
					Description: product.Description,
					Price:       product.Price,
					Stock:       product.Stock,
				},
			})
		}

		// 注文データを構築
		orders = append(orders, OrderWithProducts{
			ID:        order.ID,
			UserID:    order.UserID,
			Products:  productsInfo,
			Total:     order.Total,
			Status:    order.Status,
			OrderedAt: order.OrderedAt,
		})
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

	// 注文をデータベースに追加
	_, err = orderCollection.InsertOne(context.TODO(), order)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated) // 注文追加の成功レスポンス
}
