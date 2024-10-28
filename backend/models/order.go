package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Order struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID    primitive.ObjectID `bson:"userID" json:"userID"`
	Products  []OrderProduct     `json:"products"`
	Total     float64            `json:"totalAmount"`
	Status    string             `json:"status"`
	OrderedAt primitive.DateTime `json:"orderedAt"`
}

type OrderProduct struct {
	ProductID primitive.ObjectID `json:"productID"`
	Quantity  int                `json:"quantity"`
}
