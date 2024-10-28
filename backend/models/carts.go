// /models/cart.go
package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Cart struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID    primitive.ObjectID `bson:"userID" json:"userID"`
	Products  []CartProduct      `bson:"products" json:"products"`
	CreatedAt primitive.DateTime `bson:"createdAt" json:"createdAt"`
	UpdatedAt primitive.DateTime `bson:"updatedAt" json:"updatedAt"`
}

type CartProduct struct {
	ProductID primitive.ObjectID `bson:"productID" json:"productID"`
	Quantity  int                `bson:"quantity" json:"quantity"`
}
