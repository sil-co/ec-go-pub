// controllers/payment_controller.go
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

var paymentCollection *mongo.Collection // MongoDBのコレクション

func InitPaymentController(collection *mongo.Collection) {
	paymentCollection = collection
}

// payments
func GetPayments(w http.ResponseWriter, r *http.Request) {
	// MongoDBから全ての支払いを取得
	cursor, err := paymentCollection.Find(context.TODO(), bson.M{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO())

	var payments []models.Payment
	for cursor.Next(context.TODO()) {
		var payment models.Payment
		if err := cursor.Decode(&payment); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		payments = append(payments, payment) // 支払い情報をリストに追加
	}

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(payments) // 支払いリストをJSONで返す
}

// paryment
func GetPaymentByID(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id") // クエリパラメータからIDを取得
	paymentID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		http.Error(w, "Invalid ID format", http.StatusBadRequest)
		return
	}

	var payment models.Payment
	err = paymentCollection.FindOne(context.TODO(), bson.M{"_id": paymentID}).Decode(&payment)
	if err != nil {
		http.Error(w, "Payment not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(payment) // 支払い情報をJSONで返す
}

func AddToPayment(w http.ResponseWriter, r *http.Request) {
	var payment models.Payment
	err := json.NewDecoder(r.Body).Decode(&payment)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// 支払いに必要な情報をセット
	payment.ID = primitive.NewObjectID()
	payment.PaidAt = primitive.NewDateTimeFromTime(time.Now())

	_, err = paymentCollection.InsertOne(context.TODO(), payment)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated) // 成功レスポンスを返す
}

func UpdatePayment(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id")
	paymentID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		http.Error(w, "Invalid ID format", http.StatusBadRequest)
		return
	}

	var payment models.Payment
	err = json.NewDecoder(r.Body).Decode(&payment)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// 更新内容をMongoDBに適用
	update := bson.M{
		"$set": bson.M{
			"amount":        payment.Amount,
			"paymentMethod": payment.PaymentMethod,
			"status":        payment.Status,
			"paidAt":        primitive.NewDateTimeFromTime(time.Now()),
		},
	}

	_, err = paymentCollection.UpdateOne(context.TODO(), bson.M{"_id": paymentID}, update)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK) // 成功レスポンスを返す
}

func DeletePayment(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id")
	paymentID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		http.Error(w, "Invalid ID format", http.StatusBadRequest)
		return
	}

	_, err = paymentCollection.DeleteOne(context.TODO(), bson.M{"_id": paymentID})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent) // 削除成功のレスポンス
}
