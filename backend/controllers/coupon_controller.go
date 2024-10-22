// controllers/coupon_controller.go
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

var couponCollection *mongo.Collection // MongoDBのコレクション

func InitCouponController(collection *mongo.Collection) {
	couponCollection = collection
}

// coupons
func GetCoupons(w http.ResponseWriter, r *http.Request) {
	// 現在の日時を基準に有効なクーポンを取得
	filter := bson.M{
		"isActive":   true,
		"validFrom":  bson.M{"$lte": primitive.NewDateTimeFromTime(time.Now())},
		"validUntil": bson.M{"$gte": primitive.NewDateTimeFromTime(time.Now())},
	}

	cursor, err := couponCollection.Find(context.TODO(), filter) // フィルタでクーポンを検索
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO()) // カーソルのクローズ

	var coupons []models.Coupon
	for cursor.Next(context.TODO()) {
		var coupon models.Coupon
		if err := cursor.Decode(&coupon); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		coupons = append(coupons, coupon) // 有効なクーポンをスライスに追加
	}

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(coupons) // クーポンリストをJSONで返す
}

// coupon
func GetCoupon(w http.ResponseWriter, r *http.Request) {
	code := r.URL.Query().Get("code") // クーポンコードをクエリから取得
	if code == "" {
		http.Error(w, "クーポンコードが必要です", http.StatusBadRequest)
		return
	}

	var coupon models.Coupon
	err := couponCollection.FindOne(context.TODO(), bson.M{"code": code}).Decode(&coupon)
	if err != nil {
		http.Error(w, "クーポンが見つかりません", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(coupon) // クーポン情報をJSONで返す
}

func AddToCoupon(w http.ResponseWriter, r *http.Request) {
	var coupon models.Coupon
	err := json.NewDecoder(r.Body).Decode(&coupon) // リクエストボディをCouponにデコード
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// クーポンのフィールドを初期化
	coupon.ID = primitive.NewObjectID()
	coupon.ValidFrom = primitive.NewDateTimeFromTime(time.Now()) // 現在の時刻を設定
	coupon.IsActive = true

	_, err = couponCollection.InsertOne(context.TODO(), coupon) // クーポンをMongoDBに追加
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated) // 成功レスポンス
	w.Write([]byte("クーポンが正常に追加されました"))
}
