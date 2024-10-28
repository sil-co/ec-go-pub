// utils/mongo.go
package utils

import (
	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var client *mongo.Client

func ConnectMongoDB() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var err error
	client, err = mongo.Connect(ctx, options.Client().ApplyURI("mongodb://admin:thepassofmongo@localhost:27017"))
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("MongoDB connected!")
}

func GetMongoClient() *mongo.Client {
	return client
}
