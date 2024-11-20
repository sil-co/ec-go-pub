package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Order struct {
	ID           primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID       primitive.ObjectID `bson:"userID" json:"userID"`
	OrderProduct []OrderProduct     `json:"orderProduct"`
	Total        float64            `json:"totalAmount"`
	Status       string             `json:"status"`
	OrderedAt    primitive.DateTime `json:"orderedAt"`
}

type OrderProduct struct {
	Product  Product `json:"product"`
	Quantity int     `json:"quantity"`
}
