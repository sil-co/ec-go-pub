// controllers/cart_controller.go
package controllers

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"ec-api/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

// type CartProductDetail struct {
// 	ProductID   primitive.ObjectID `json:"productID"`
// 	Quantity    int                `json:"quantity"`
// 	Name        string             `json:"name"`
// 	Description string             `json:"description"`
// 	Price       float64            `json:"price"`
// 	Stock       int                `json:"stock"`
// }

var cartCollection *mongo.Collection // MongoDBのコレクション

func InitCartController(collection *mongo.Collection) {
	cartCollection = collection
}

// carts
func GetCarts(w http.ResponseWriter, r *http.Request) {
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

	var cart models.Cart

	err = cartCollection.FindOne(context.TODO(), bson.M{"userID": userID}).Decode(&cart)
	if err != nil {
		// カートが見つからない場合、空のカートを返す
		cart = models.Cart{
			UserID:   userID,
			Products: []models.CartProduct{}, // 空の製品リスト
		}
	} else {
		// カート内の各製品について詳細を取得
		for i := range cart.Products {
			var product models.Product
			err := productCollection.FindOne(context.TODO(), bson.M{"_id": cart.Products[i].Product.ID}).Decode(&product)
			if err != nil {
				// 製品が見つからない場合、その製品をカートから除外
				cart.Products = append(cart.Products[:i], cart.Products[i+1:]...)
				continue
			}
			// 詳細情報を埋める
			cart.Products[i].Product = product
		}
	}

	// カートのJSONをレスポンスとして送信
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(cart); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

func DeleteCarts(w http.ResponseWriter, r *http.Request) {
	// AuthorizationヘッダーからJWTトークンを取得
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Missing token", http.StatusUnauthorized)
		return
	}

	// トークンの検証
	claims, err := ValidateJWT(tokenString)
	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	userID := claims.UserID

	// ユーザーのカートを削除
	filter := bson.M{"userID": userID}
	_, err = cartCollection.DeleteOne(context.TODO(), filter)
	if err != nil {
		http.Error(w, "Failed to clear cart", http.StatusInternalServerError)
		return
	}

	// 成功レスポンスを送信
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	response := map[string]string{"message": "Cart cleared successfully"}
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

// cart
func GetCart(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("userID") // クエリパラメータからユーザーIDを取得
	var cart models.Cart
	err := cartCollection.FindOne(context.TODO(), bson.M{"userID": userID}).Decode(&cart)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	json.NewEncoder(w).Encode(cart)
}

func AddToCart(w http.ResponseWriter, r *http.Request) {
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

	var cartProduct models.CartProduct
	err = json.NewDecoder(r.Body).Decode(&cartProduct)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	userID := claims.UserID

	var product models.Product
	err = productCollection.FindOne(context.TODO(), bson.M{"_id": cartProduct.Product.ID}).Decode(&product)
	if err == mongo.ErrNoDocuments {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// 製品の詳細を更新してセット
	cartProduct.Product = product

	// 既存のカートを取得
	var existingCart models.Cart
	err = cartCollection.FindOne(context.TODO(), bson.M{"userID": userID}).Decode(&existingCart)

	if err == mongo.ErrNoDocuments {
		// カートが存在しない場合、新しいカートを作成
		newCart := models.Cart{
			UserID:    userID,
			Products:  []models.CartProduct{cartProduct}, // 新しい商品を追加
			CreatedAt: primitive.NewDateTimeFromTime(time.Now()),
			UpdatedAt: primitive.NewDateTimeFromTime(time.Now()),
		}

		_, err = cartCollection.InsertOne(context.TODO(), newCart)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusCreated)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// カートが存在する場合、商品のリストを更新
	productExists := false

	for i, existingProduct := range existingCart.Products {
		if existingProduct.Product.ID == cartProduct.Product.ID {
			// 同じ商品が存在する場合、数量を更新
			existingCart.Products[i].Quantity += cartProduct.Quantity
			productExists = true
			break
		}
	}

	// 同じ商品が存在しない場合、新しい商品を追加
	if !productExists {
		existingCart.Products = append(existingCart.Products, cartProduct)
	}

	// 更新日時を設定
	existingCart.UpdatedAt = primitive.NewDateTimeFromTime(time.Now())

	// カートを更新
	_, err = cartCollection.UpdateOne(
		context.TODO(),
		bson.M{"userID": userID},
		bson.M{"$set": existingCart},
	)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func DeleteCart(w http.ResponseWriter, r *http.Request) {
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

	// クエリパラメータからproductIdとquantityを取得
	productID := r.URL.Query().Get("productId")
	if productID == "" {
		http.Error(w, "Missing productId", http.StatusBadRequest)
		return
	}

	quantityStr := r.URL.Query().Get("quantity")
	if quantityStr == "" {
		http.Error(w, "Missing quantity", http.StatusBadRequest)
		return
	}

	quantity, err := strconv.Atoi(quantityStr)
	if err != nil {
		http.Error(w, "Invalid quantity", http.StatusBadRequest)
		return
	}

	userID := claims.UserID

	// カートを取得
	var existingCart models.Cart
	err = cartCollection.FindOne(context.TODO(), bson.M{"userID": userID}).Decode(&existingCart)
	if err == mongo.ErrNoDocuments {
		http.Error(w, "Cart not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	productObjectID, err := primitive.ObjectIDFromHex(productID)
	if err != nil {
		http.Error(w, "Invalid productId", http.StatusBadRequest)
		return
	}

	// 商品がカートにあるかチェック
	productIndex := -1
	for i, existingProduct := range existingCart.Products {
		if existingProduct.Product.ID == productObjectID {
			productIndex = i
			break
		}
	}

	if productIndex == -1 {
		http.Error(w, "Product not found in cart", http.StatusNotFound)
		return
	}

	// 数量を減らし、0になったら削除
	if existingCart.Products[productIndex].Quantity > quantity {
		existingCart.Products[productIndex].Quantity -= quantity
	} else {
		existingCart.Products = append(existingCart.Products[:productIndex], existingCart.Products[productIndex+1:]...)
	}

	// 更新日時を設定
	existingCart.UpdatedAt = primitive.NewDateTimeFromTime(time.Now())

	// カートを更新
	_, err = cartCollection.UpdateOne(
		context.TODO(),
		bson.M{"userID": userID},
		bson.M{"$set": existingCart},
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}
