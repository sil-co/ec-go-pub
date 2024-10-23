// controllers/cart_controller.go
package controllers

import (
	"context"
	"encoding/json"
	"net/http"

	"ec-api/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

var cartCollection *mongo.Collection // MongoDBのコレクション

func InitCartController(collection *mongo.Collection) {
	cartCollection = collection
}

// carts
func GetCarts(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("userId") // クエリパラメータからユーザーIDを取得
	var cart models.Cart

	// ユーザーIDに基づいてカートを取得
	err := cartCollection.FindOne(context.TODO(), bson.M{"userId": userID}).Decode(&cart)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	// カートの情報をJSON形式で返す
	json.NewEncoder(w).Encode(cart)
}

// cart
func GetCart(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("userId") // クエリパラメータからユーザーIDを取得
	var cart models.Cart
	err := cartCollection.FindOne(context.TODO(), bson.M{"userId": userID}).Decode(&cart)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	json.NewEncoder(w).Encode(cart)
}

func AddToCart(w http.ResponseWriter, r *http.Request) {
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

	var cart models.Cart
	err = json.NewDecoder(r.Body).Decode(&cart)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	cart.UserID = claims.UserID

	_, err = cartCollection.InsertOne(context.TODO(), cart)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}
