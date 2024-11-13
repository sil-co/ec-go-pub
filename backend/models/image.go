package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Image struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	ProductID primitive.ObjectID `bson:"productID" json:"productID"`
	URL       string             `bson:"url"`
	Filename  string             `bson:"filename"`
	CreatedAt primitive.DateTime `json:"createdAt"`
}
