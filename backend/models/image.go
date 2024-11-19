package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Image struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID    primitive.ObjectID `bson:"userID" json:"userID"`
	Path      string             `bson:"path" json:"path"`
	Imagename string             `bson:"imagename" json:"imagename"`
	CreatedAt primitive.DateTime `json:"createdAt"`
}
