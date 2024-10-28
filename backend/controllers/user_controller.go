// controllers/user_controller.go
package controllers

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"ec-api/models"
	"ec-api/utils"

	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var userCollection *mongo.Collection // MongoDBのコレクション
var jwtKey = []byte("your-secret-key")

// JWTペイロード
type Claims struct {
	UserID               primitive.ObjectID `json:"userID"` // MongoDBのユーザーID
	Username             string             `json:"username"`
	jwt.RegisteredClaims                    // 期限など標準のクレーム
}

func InitUserController(collection *mongo.Collection) {
	userCollection = collection
}

// auth
func CheckAuth(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Token string `json:"token"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	// claims := &Claims{}

	// token, err := jwt.ParseWithClaims(req.Token, claims, func(token *jwt.Token) (interface{}, error) {
	// 	return jwtKey, nil
	// })

	_, err := ValidateJWT(req.Token)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	// トークンからusernameを取得
	w.WriteHeader(http.StatusOK)
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

// user
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

	// expirationTime := time.Now().Add(24 * time.Hour)
	// JWT生成
	// claims := &Claims{
	// 	Username: user.Username,
	// 	RegisteredClaims: jwt.RegisteredClaims{
	// 		ExpiresAt: jwt.NewNumericDate(expirationTime),
	// 	},
	// }
	// token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	// tokenString, err := token.SignedString(jwtKey)

	tokenString, err := GenerateJWT(user.ID, user.Username)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// トークンを返却
	json.NewEncoder(w).Encode(map[string]string{
		"token": tokenString,
	})

	// w.WriteHeader(http.StatusCreated)
	// json.NewEncoder(w).Encode(map[string]string{"message": "User registered"})

	// response := map[string]interface{}{
	// 	"message": "Signup successful",
	// 	"userID":  user.ID.Hex(), // ObjectIDを文字列に変換
	// }
	// w.Header().Set("Content-Type", "application/json")
	// json.NewEncoder(w).Encode(response)
}

// login
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

	// expirationTime := time.Now().Add(24 * time.Hour)
	// // JWT生成
	// claims := &Claims{
	// 	Username: user.Username,
	// 	RegisteredClaims: jwt.RegisteredClaims{
	// 		ExpiresAt: jwt.NewNumericDate(expirationTime),
	// 	},
	// }
	// token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	// tokenString, err := token.SignedString(jwtKey)
	tokenString, err := GenerateJWT(user.ID, user.Username)

	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// トークンを返却
	json.NewEncoder(w).Encode(map[string]string{
		"token": tokenString,
	})

	// json.NewEncoder(w).Encode(map[string]string{"message": "Login successful"})
	// response := map[string]interface{}{
	// 	"message": "Login successful",
	// 	"userID":  user.ID.Hex(), // ObjectIDを文字列に変換
	// }
	// w.Header().Set("Content-Type", "application/json")
	// json.NewEncoder(w).Encode(response)
}

// JWTトークンを生成する関数
func GenerateJWT(userID primitive.ObjectID, username string) (string, error) {
	expirationTime := time.Now().Add(24 * time.Hour) // トークンの有効期限を24時間後に設定
	claims := &Claims{
		UserID:   userID,
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	// クレームからトークンを生成し、署名します
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtKey)
}

// Tokenの検証
func ValidateJWT(tokenString string) (*Claims, error) {
	claims := &Claims{}

	// トークンを解析し、クレームを取得
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})

	if err != nil || !token.Valid {
		return nil, err
	}

	return claims, nil
}
