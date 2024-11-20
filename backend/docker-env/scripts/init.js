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

// サンプルユーザーの挿入
db.users.insertMany([
  {
    username: "john_doe",
    email: "john.doe@example.com",
    password: "hashed_password_1", // ここは実際のハッシュ化されたパスワードに置き換えてください
    role: "customer",
    createdAt: new Date(),
  },
  {
    username: "admin_user",
    email: "admin@example.com",
    password: "hashed_password_2", // ここも実際のハッシュ化されたパスワードに置き換えてください
    role: "admin",
    createdAt: new Date(),
  },
]);

// サンプル製品の挿入
db.products.insertMany([
  {
    userID: db.users.findOne({ username: "john_doe" })._id,
    imageID: new ObjectId(), // 画像IDを適切に設定
    name: "Example Product 1",
    description: "This is an example product.",
    price: 19.99,
    stock: 100,
    category: "Electronics",
    createdAt: new Date(),
  },
  {
    userID: db.users.findOne({ username: "john_doe" })._id,
    imageID: new ObjectId(), // 画像IDを適切に設定
    name: "Example Product 2",
    description: "Another example product.",
    price: 29.99,
    stock: 50,
    category: "Clothing",
    createdAt: new Date(),
  },
]);

// サンプル注文の挿入
db.orders.insertMany([
  {
    userID: db.users.findOne({ username: "john_doe" })._id,
    orderProduct: [
      {
        product: db.products.findOne({ name: "Example Product 1" }),
        quantity: 2,
      },
    ],
    total: 39.98,
    status: "pending",
    orderedAt: new Date(),
  },
  {
    userID: db.users.findOne({ username: "admin_user" })._id,
    orderProduct: [
      {
        product: db.products.findOne({ name: "Example Product 2" }),
        quantity: 1,
      },
    ],
    total: 29.99,
    status: "shipped",
    orderedAt: new Date(),
  },
]);

// サンプルカートの挿入
db.carts.insertMany([
  {
    userID: db.users.findOne({ username: "john_doe" })._id,
    products: [
      {
        product: db.products.findOne({ name: "Example Product 1" }),
        quantity: 1,
      },
      {
        product: db.products.findOne({ name: "Example Product 2" }),
        quantity: 2,
      },
    ],
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    userID: db.users.findOne({ username: "admin_user" })._id,
    products: [
      {
        product: db.products.findOne({ name: "Example Product 2" }),
        quantity: 1,
      },
    ],
    createdAt: new Date(),
    updatedAt: new Date(),
  },
]);

print("MongoDB initialized successfully.");
