// /models/coupon.go
package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Coupon struct {
	ID                 primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Code               string             `bson:"code" json:"code"`
	DiscountPercentage float64            `bson:"discountPercentage" json:"discountPercentage"`
	ValidFrom          primitive.DateTime `bson:"validFrom" json:"validFrom"`
	ValidUntil         primitive.DateTime `bson:"validUntil" json:"validUntil"`
	IsActive           bool               `bson:"isActive" json:"isActive"`
}
