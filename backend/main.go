package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/mongo"

	"ec-api/controllers"
	"ec-api/utils"
)

var userCollection *mongo.Collection
var productCollection *mongo.Collection
var imageCollection *mongo.Collection
var cartCollection *mongo.Collection
var categoryCollection *mongo.Collection
var orderCollection *mongo.Collection
var couponsCollection *mongo.Collection
var paymentCollection *mongo.Collection

// cross origin許可
func enableCORS(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// OPTIONSリクエストへの対応
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		h.ServeHTTP(w, r)
	})
}

func main() {
	utils.SaveCollections()

	utils.ConnectMongoDB()

	// MongoDBのコレクションを設定
	userCollection = utils.GetMongoClient().Database("ec-db").Collection("users")
	productCollection = utils.GetMongoClient().Database("ec-db").Collection("products")
	imageCollection = utils.GetMongoClient().Database("ec-db").Collection("images")
	cartCollection = utils.GetMongoClient().Database("ec-db").Collection("carts")
	categoryCollection = utils.GetMongoClient().Database("ec-db").Collection("categories")
	orderCollection = utils.GetMongoClient().Database("ec-db").Collection("orders")
	couponsCollection = utils.GetMongoClient().Database("ec-db").Collection("coupons")
	paymentCollection = utils.GetMongoClient().Database("ec-db").Collection("payments")

	// コントローラーの初期化
	controllers.InitUserController(userCollection)
	controllers.InitProductController(productCollection)
	controllers.InitImageController(imageCollection)
	controllers.InitCartController(cartCollection)
	controllers.InitCategoryController(categoryCollection)
	controllers.InitOrderController(orderCollection)
	controllers.InitCouponController(couponsCollection)
	controllers.InitPaymentController(paymentCollection)

	r := mux.NewRouter()

	// ルート設定 RESTfull設計

	// users
	r.HandleFunc("/users", controllers.GetUsers).Methods("GET")
	// user
	// r.HandleFunc("/user", controllers.getUser).Methods("GET")
	r.HandleFunc("/user", controllers.AddToUser).Methods("POST")
	// r.HandleFunc("/user", controllers.updateUser).Methods("PUT")
	// r.HandleFunc("/user", controllers.deleteUser).Methods("DELETE")
	// login
	r.HandleFunc("/login", controllers.LoginUser).Methods("POST")
	// checkauth
	r.HandleFunc("/auth", controllers.CheckAuth).Methods("POST")

	// carts
	r.HandleFunc("/carts", controllers.GetCarts).Methods("GET")
	// cart
	r.HandleFunc("/cart", controllers.GetCart).Methods("GET")
	r.HandleFunc("/cart", controllers.AddToCart).Methods("POST")
	// r.HandleFunc("/cart", controllers.UpdateCart).Methods("PUT")
	r.HandleFunc("/cart", controllers.DeleteCart).Methods("DELETE")

	// products
	r.HandleFunc("/products", controllers.GetProductsByUser).Methods("GET")
	r.HandleFunc("/products/all", controllers.GetProductsAll).Methods("GET")
	// product
	// r.HandleFunc("/product", controllers.getProduct).Methods("GET")
	r.HandleFunc("/product", controllers.AddToProduct).Methods("POST")
	r.HandleFunc("/product/{ProductId}", controllers.UpdateProduct).Methods("PUT")
	r.HandleFunc("/product/{ProductId}", controllers.DeleteProduct).Methods("DELETE")

	// image
	// r.HandleFunc("/image", controllers.GetImage).Methods("GET")
	r.HandleFunc("/image", controllers.UploadImage).Methods("POST")
	// r.HandleFunc("/image/{ImageId}", controllers.UpdateImage).Methods("PUT")
	// r.HandleFunc("/image/{ImageId}", controllers.DeleteImage).Methods("DELETE")

	// categories
	r.HandleFunc("/categories", controllers.GetCategories).Methods("GET")
	// category
	// r.HandleFunc("/category", controllers.getCategory).Methods("GET")
	r.HandleFunc("/category", controllers.AddToCategory).Methods("POST")
	// r.HandleFunc("/category", controllers.updateCategory).Methods("PUT")
	// r.HandleFunc("/category", controllers.deleteCategory).Methods("DELETE")

	// orders
	r.HandleFunc("/orders", controllers.GetOrders).Methods("GET")
	// r.HandleFunc("/orders", controllers.createOrders).Methods("POST")
	// r.HandleFunc("/orders", controllers.updateOrders).Methods("PUT")
	// r.HandleFunc("/orders", controllers.deleteOrders).Methods("DELETE")
	// order
	// r.HandleFunc("/order", controllers.getOrder).Methods("GET")
	r.HandleFunc("/order", controllers.AddToOrder).Methods("POST")
	// r.HandleFunc("/order", controllers.updateOrder).Methods("PUT")
	// r.HandleFunc("/order", controllers.deleteOrder).Methods("DELETE")

	// coupons
	r.HandleFunc("/coupons", controllers.GetCoupons).Methods("GET")
	// r.HandleFunc("/coupons", controllers.createCoupons).Methods("POST")
	// r.HandleFunc("/coupons", controllers.updateCoupons).Methods("PUT")
	// r.HandleFunc("/coupons", controllers.deleteCoupons).Methods("DELETE")
	// coupon
	// r.HandleFunc("/coupon", controllers.getCoupon).Methods("GET")
	r.HandleFunc("/coupon", controllers.AddToCoupon).Methods("POST")
	// r.HandleFunc("/coupon", controllers.updateCoupon).Methods("PUT")
	// r.HandleFunc("/coupon", controllers.deleteCoupon).Methods("DELETE")

	// payments
	r.HandleFunc("/payments", controllers.GetPayments).Methods("GET")
	// r.HandleFunc("/payments", controllers.createPayments).Methods("POST")
	// r.HandleFunc("/payments", controllers.updatePayments).Methods("PUT")
	// r.HandleFunc("/payments", controllers.deletePayments).Methods("DELETE")
	// payment
	// r.HandleFunc("/payment", controllers.getPayment).Methods("GET")
	r.HandleFunc("/payment", controllers.AddToPayment).Methods("POST")
	// r.HandleFunc("/payment", controllers.updatePayment).Methods("PUT")
	// r.HandleFunc("/payment", controllers.deletePayment).Methods("DELETE")

	fmt.Println("Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", enableCORS(r)))
}
