// データベース接続設定
const db = connect("mongodb://localhost:27017/ec-db");

// コレクションの初期化（既存のものを削除して作り直す）
db.users.drop();
db.products.drop();
db.orders.drop();
db.categories.drop();

// ユーザーデータの挿入
db.users.insertMany([
  {
    username: "user1",
    email: "user1@example.com",
    password: "hashed_password1", // ハッシュ化されたパスワードを保存する想定
    role: "customer",
    createdAt: new Date(),
  },
  {
    username: "admin",
    email: "admin@example.com",
    password: "hashed_password2",
    role: "admin",
    createdAt: new Date(),
  }
]);

// 商品カテゴリの挿入
db.categories.insertMany([
  { name: "Electronics", description: "Electronics gadgets" },
  { name: "Books", description: "Books and stationery" },
  { name: "Clothing", description: "Apparel and accessories" }
]);

// 商品データの挿入
db.products.insertMany([
  {
    name: "Smartphone",
    description: "Latest model with high specs",
    price: 699.99,
    stock: 50,
    category: "Electronics",
    createdAt: new Date()
  },
  {
    name: "Novel",
    description: "A best-selling novel",
    price: 19.99,
    stock: 200,
    category: "Books",
    createdAt: new Date()
  },
  {
    name: "T-Shirt",
    description: "Comfortable cotton t-shirt",
    price: 9.99,
    stock: 100,
    category: "Clothing",
    createdAt: new Date()
  }
]);

// 注文データの挿入
db.orders.insertMany([
  {
    userId: db.users.findOne({ username: "user1" })._id,
    products: [
      { productId: db.products.findOne({ name: "Smartphone" })._id, quantity: 1 },
      { productId: db.products.findOne({ name: "Novel" })._id, quantity: 2 }
    ],
    totalAmount: 739.97,
    status: "pending",
    orderedAt: new Date()
  }
]);

print("MongoDB initialized successfully.");