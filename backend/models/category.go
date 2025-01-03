// /models/cart.go
package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Category struct {
	ID          primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Name        string             `json:"name"`
	Description string             `json:"description"`
}
