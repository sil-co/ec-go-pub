// controllers/category_controller.go
package controllers

import (
	"context"
	"encoding/json"
	"net/http"

	"ec-api/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

var categoryCollection *mongo.Collection // MongoDBのコレクション

func InitCategoryController(collection *mongo.Collection) {
	categoryCollection = collection
}

func GetCategories(w http.ResponseWriter, r *http.Request) {
	var categories []models.Category
	cursor, err := categoryCollection.Find(context.TODO(), bson.M{}) // すべてのカテゴリーを取得

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO())

	for cursor.Next(context.TODO()) {
		var category models.Category
		if err := cursor.Decode(&category); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		categories = append(categories, category) // カテゴリーをスライスに追加
	}

	if err := cursor.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(categories) // カテゴリーのリストをJSON形式で返す
}

func AddToCategory(w http.ResponseWriter, r *http.Request) {
	var category models.Category
	err := json.NewDecoder(r.Body).Decode(&category)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	_, err = categoryCollection.InsertOne(context.TODO(), category)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated) // カテゴリー追加の成功レスポンス
}
