// データベース接続設定
const db = connect("mongodb://localhost:27017/ec-db");

// コレクションの初期化（既存のものを削除して作り直す）
db.users.drop();
db.products.drop();
db.orders.drop();
db.categories.drop();
db.carts.drop();
db.payments.drop();
db.coupons.drop();

// usersコレクション: usernameとemailに一意インデックスを設定
db.users.createIndex({ username: 1 }, { unique: true });
db.users.createIndex({ email: 1 }, { unique: true });

// couponsコレクション: codeに一意インデックスを設定
db.coupons.createIndex({ code: 1 }, { unique: true });

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
  },
]);

// 商品カテゴリの挿入
db.categories.insertMany([
  { name: "Electronics", description: "Electronics gadgets" },
  { name: "Books", description: "Books and stationery" },
  { name: "Clothing", description: "Apparel and accessories" },
]);

// 商品データの挿入
db.products.insertMany([
  {
    userId: db.users.findOne({ username: "user1" })._id,
    name: "Smartphone",
    description: "Latest model with high specs",
    price: 6999,
    stock: 50,
    category: "Electronics",
    createdAt: new Date(),
  },
  {
    userId: db.users.findOne({ username: "user1" })._id,
    name: "Novel",
    description: "A best-selling novel",
    price: 1999,
    stock: 200,
    category: "Books",
    createdAt: new Date(),
  },
  {
    userId: db.users.findOne({ username: "user1" })._id,
    name: "T-Shirt",
    description: "Comfortable cotton t-shirt",
    price: 999,
    stock: 100,
    category: "Clothing",
    createdAt: new Date(),
  },
]);

// 注文データの挿入
db.orders.insertMany([
  {
    userId: db.users.findOne({ username: "user1" })._id,
    products: [
      {
        productId: db.products.findOne({ name: "Smartphone" })._id,
        quantity: 1,
      },
      { productId: db.products.findOne({ name: "Novel" })._id, quantity: 2 },
    ],
    totalAmount: 739.97,
    status: "pending",
    orderedAt: new Date(),
  },
]);

db.carts.insertMany([
  {
    userId: db.users.findOne({ username: "user1" })._id, // カート所有者
    products: [
      { productId: db.products.findOne({ name: "T-Shirt" })._id, quantity: 2 },
      { productId: db.products.findOne({ name: "Novel" })._id, quantity: 1 },
    ],
    createdAt: new Date(),
    updatedAt: new Date(),
  },
]);

db.payments.insertMany([
  {
    orderId: db.orders.findOne({ status: "pending" })._id,
    amount: 739.97,
    paymentMethod: "credit_card", // クレジットカード、PayPalなど
    status: "completed",
    paidAt: new Date(),
  },
]);

db.coupons.insertMany([
  {
    code: "DISCOUNT10",
    discountPercentage: 10,
    validFrom: new Date("2024-10-01"),
    validUntil: new Date("2024-12-31"),
    isActive: true,
  },
]);

print("MongoDB initialized successfully.");
