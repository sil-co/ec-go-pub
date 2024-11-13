package controllers

import (
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"ec-api/models"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var imageCollection *mongo.Collection // MongoDBのコレクション

func InitImageController(collection *mongo.Collection) {
	imageCollection = collection
}

const (
	MaxFileSize   = 2 * 1024 * 1024 // 2MB
	ImageSavePath = "./uploads/"
	MongoURI      = "mongodb://localhost:27017"
)

var (
	AllowedExtensions = []string{".jpg", ".png", ".webp", ".gif"}
)

// image
func UploadImage(w http.ResponseWriter, r *http.Request) {
	// AuthorizationヘッダーからJWTトークンを取得
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		http.Error(w, "Missing token", http.StatusUnauthorized)
		return
	}

	claims, err := ValidateJWT(tokenString)
	userID := claims.UserID
	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	var product models.Product
	err = json.NewDecoder(r.Body).Decode(&product)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// 受け取ったuserIDをProductに追加
	product.UserID = userID

	// 現在の日時をCreatedAtに設定
	product.CreatedAt = primitive.NewDateTimeFromTime(time.Now())

	_, err = productCollection.InsertOne(context.TODO(), product)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func UploadHandler(w http.ResponseWriter, r *http.Request) {
	client, err := mongo.NewClient(options.Client().ApplyURI(MongoURI))
	if err != nil {
		log.Fatal(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	err = client.Connect(ctx)
	if err != nil {
		log.Fatal(err)
	}
	imageCollection = client.Database("imageDB").Collection("images")

	r.ParseMultipartForm(MaxFileSize)

	file, handler, err := r.FormFile("image")
	if err != nil {
		http.Error(w, "Image file is required", http.StatusBadRequest)
		return
	}
	defer file.Close()

	if handler.Size > MaxFileSize {
		http.Error(w, "File size exceeds 2MB", http.StatusBadRequest)
		return
	}

	ext := filepath.Ext(handler.Filename)
	if !IsAllowedExtension(ext) {
		http.Error(w, "File type not allowed", http.StatusBadRequest)
		return
	}

	filename := primitive.NewObjectID().Hex() + ext
	filePath := ImageSavePath + filename
	outFile, err := os.Create(filePath)
	if err != nil {
		http.Error(w, "Unable to save the image", http.StatusInternalServerError)
		return
	}
	defer outFile.Close()

	_, err = io.Copy(outFile, file)
	if err != nil {
		http.Error(w, "Failed to write image to disk", http.StatusInternalServerError)
		return
	}

	image := models.Image{
		URL:      "http://localhost:8080/images/" + filename,
		Filename: filename,
	}

	_, err = imageCollection.InsertOne(context.Background(), image)
	if err != nil {
		http.Error(w, "Failed to save image metadata", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(image)
}

func IsAllowedExtension(ext string) bool {
	for _, allowedExt := range AllowedExtensions {
		if ext == allowedExt {
			return true
		}
	}
	return false
}
