// /models/cart.go
package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Cart struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID    primitive.ObjectID `bson:"userId" json:"userId"`
	Products  []CartProduct      `bson:"products" json:"products"`
	CreatedAt primitive.DateTime `bson:"createdAt" json:"createdAt"`
	UpdatedAt primitive.DateTime `bson:"updatedAt" json:"updatedAt"`
}

type CartProduct struct {
	ProductID primitive.ObjectID `bson:"productId" json:"productId"`
	Quantity  int                `bson:"quantity" json:"quantity"`
}
