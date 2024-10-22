// /models/payment.go
package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Payment struct {
	ID            primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	OrderID       primitive.ObjectID `bson:"orderId" json:"orderId"`
	Amount        float64            `bson:"amount" json:"amount"`
	PaymentMethod string             `bson:"paymentMethod" json:"paymentMethod"`
	Status        string             `bson:"status" json:"status"`
	PaidAt        primitive.DateTime `bson:"paidAt" json:"paidAt"`
}
