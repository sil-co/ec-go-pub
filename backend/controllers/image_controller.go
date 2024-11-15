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
	"ec-api/utils"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

var imageCollection *mongo.Collection // MongoDBのコレクション

func InitImageController(collection *mongo.Collection) {
	imageCollection = collection
}

const (
	MaxFileSize = 2 * 1024 * 1024 // 2MB
	MongoURI    = "mongodb://localhost:27017"
)

var (
	AllowedExtensions = []string{".jpg", ".png", ".webp", ".gif"}
)

// image
func UploadImage(w http.ResponseWriter, r *http.Request) {
	r.ParseMultipartForm(MaxFileSize)

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

	imagename := primitive.NewObjectID().Hex() + ext
	imagePath := filepath.Join(utils.GetFilePath(), "..", "resources", "images", imagename)
	outFile, err := os.Create(imagePath)
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
		Path:      filepath.Join("resources", "images", imagename),
		Imagename: imagename,
		CreatedAt: primitive.NewDateTimeFromTime(time.Now()),
	}

	image.UserID = userID

	result, err := imageCollection.InsertOne(context.TODO(), image)
	if err != nil {
		log.Println("Error inserting image metadata into MongoDB:", err)
		http.Error(w, "Failed to save image metadata", http.StatusInternalServerError)
		return
	}
	image.ID = result.InsertedID.(primitive.ObjectID)

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
