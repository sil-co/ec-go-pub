package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Product struct {
	ID          primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID      primitive.ObjectID `bson:"userID" json:"userID"`
	ImageID     primitive.ObjectID `bson:"imageID" json:"imageID"`
	Name        string             `json:"name"`
	Description string             `json:"description"`
	Price       float64            `json:"price"`
	Stock       int                `json:"stock"`
	Category    string             `json:"category"`
	CreatedAt   primitive.DateTime `json:"createdAt"`
	Image       Image              `json:"image,omitempty"`
}
