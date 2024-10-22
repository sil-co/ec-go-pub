// controllers/user_controller.go
package controllers

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"ec-api/models"
	"ec-api/utils"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var userCollection *mongo.Collection // MongoDBのコレクション

func InitUserController(collection *mongo.Collection) {
	userCollection = collection
}

// users
func GetUsers(w http.ResponseWriter, r *http.Request) {
	var users []models.User
	cursor, err := userCollection.Find(context.TODO(), bson.D{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO()) // 関数終了時にカーソルをクローズ

	for cursor.Next(context.TODO()) {
		var user models.User
		if err := cursor.Decode(&user); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		users = append(users, user) // 製品をスライスに追加
	}

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(users) // JSON形式で製品のリストをエンコードして返す
}

// /user
func GetUser(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("id") // クエリパラメータから製品IDを取得
	var user models.User

	// 製品IDをObjectIDに変換
	id, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	err = userCollection.FindOne(context.TODO(), bson.M{"_id": id}).Decode(&user) // 製品IDで検索
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	json.NewEncoder(w).Encode(user) // JSON
}

func AddToUser(w http.ResponseWriter, r *http.Request) {
	var user models.User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	// ユーザー情報のセットアップ
	user.ID = primitive.NewObjectID()
	user.CreatedAt = primitive.NewDateTimeFromTime(time.Now())

	// パスワードのハッシュ化
	hashedPassword, err := utils.HashPassword(user.Password)
	if err != nil {
		http.Error(w, "Error hashing password", http.StatusInternalServerError)
		return
	}
	user.Password = hashedPassword

	// MongoDBにユーザーを保存
	_, err = userCollection.InsertOne(context.TODO(), user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"message": "User registered"})
}

func LoginUser(w http.ResponseWriter, r *http.Request) {
	var credentials struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	err := json.NewDecoder(r.Body).Decode(&credentials)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var user models.User
	err = userCollection.FindOne(context.TODO(), bson.M{"email": credentials.Email}).Decode(&user)
	if err != nil {
		http.Error(w, "Invalid email or password", http.StatusUnauthorized)
		return
	}

	if !utils.CheckPasswordHash(credentials.Password, user.Password) {
		http.Error(w, "Invalid email or password", http.StatusUnauthorized)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{"message": "Login successful"})
}
