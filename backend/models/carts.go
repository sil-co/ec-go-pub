// /models/cart.go
package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Cart struct {
	ID          primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID      primitive.ObjectID `bson:"userID" json:"userID"`
	CartProduct []CartProduct      `bson:"cartProduct" json:"cartProduct"`
	CreatedAt   primitive.DateTime `bson:"createdAt" json:"createdAt"`
	UpdatedAt   primitive.DateTime `bson:"updatedAt" json:"updatedAt"`
}

type CartProduct struct {
	Product  Product `bson:"product" json:"product"`
	Quantity int     `bson:"quantity" json:"quantity"`
}
