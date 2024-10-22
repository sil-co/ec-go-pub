package controllers

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var client *mongo.Client

// Initialize MongoDB client
func init() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	var err error
	client, err = mongo.Connect(ctx, options.Client().ApplyURI("mongodb://admin:thepassofmongo@localhost:27017"))
	if err != nil {
		log.Fatal(err)
	}
}

// User struct to map MongoDB data
type User struct {
	Username string `json:"username"`
	Token    string `json:"token"`
}

// Auth check handler
func CheckAuth(w http.ResponseWriter, r *http.Request) {
	var user User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	collection := client.Database("ec-db").Collection("users")
	filter := bson.M{"username": user.Username, "token": user.Token}

	var foundUser User
	err = collection.FindOne(context.TODO(), filter).Decode(&foundUser)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Authorized"))
}
