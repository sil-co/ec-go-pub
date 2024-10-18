import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EC APP Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // APIからユーザーのデータを取得する関数
  // Future<List<dynamic>> fetchUsers() async {
  //   final response =
  //       await http.get(Uri.parse('http://192.168.1.97:8080/users'));
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load users');
  //   }
  // }

  // ユーザーを登録するPOSTリクエスト
  // Future<void> createUser() async {
  //   final url = Uri.parse('http://192.168.1.97:8080/user');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'username': usernameController.text,
  //       'email': emailController.text,
  //       'password': passwordController.text,
  //       'role': 'user',
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     showSnackBar('User created successfully!');
  //   } else {
  //     showSnackBar('Failed to create user: ${response.body}');
  //   }
  // }

  // APIから商品のデータを取得する関数
  // Future<List<dynamic>> fetchProducts() async {
  //   final response =
  //       await http.get(Uri.parse('http://192.168.1.97:8080/products'));
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load products');
  //   }
  // }

  // 注文を作成するPOSTリクエスト
  // Future<void> createOrder() async {
  //   final url = Uri.parse('http://192.168.1.97:8080/order');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'userId': 'user-id-here', // 実際のユーザーIDをセットする必要があります
  //       'products': [
  //         {
  //           'productId': productIdController.text,
  //           'quantity': int.parse(quantityController.text),
  //         }
  //       ],
  //       'totalAmount': 100.0, // サンプルの合計金額
  //       'status': 'pending',
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     showSnackBar('Order created successfully!');
  //   } else {
  //     showSnackBar('Failed to create order: ${response.body}');
  //   }
  // }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EC APP Demo'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'EC App Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text('Cart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrderHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfilePage()),
                );
              },
            ),
            const Divider(), // Divider to separate menu items
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Logout logic
                Navigator.pop(context); // Close drawer after logout
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Create User'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateUserPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Create Order'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateOrderPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: SingleChildScrollView(
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const SectionTitle(title: 'Users'),
      //         FutureBuilder<List<dynamic>>(
      //           future: fetchUsers(),
      //           builder: (context, snapshot) {
      //             if (snapshot.connectionState == ConnectionState.waiting) {
      //               return const CircularProgressIndicator();
      //             } else if (snapshot.hasError) {
      //               return Text('Error: ${snapshot.error}');
      //             } else {
      //               return ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: const NeverScrollableScrollPhysics(),
      //                 itemCount: snapshot.data!.length,
      //                 itemBuilder: (context, index) {
      //                   final user = snapshot.data![index];
      //                   return ListTile(
      //                     title: Text(user['username']),
      //                     subtitle: Text(user['email']),
      //                   );
      //                 },
      //               );
      //             }
      //           },
      //         ),
      //         const SizedBox(height: 16),
      //         const SectionTitle(title: 'Products'),
      //         FutureBuilder<List<dynamic>>(
      //           future: fetchProducts(),
      //           builder: (context, snapshot) {
      //             if (snapshot.connectionState == ConnectionState.waiting) {
      //               return const CircularProgressIndicator();
      //             } else if (snapshot.hasError) {
      //               return Text('Error: ${snapshot.error}');
      //             } else {
      //               return ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: const NeverScrollableScrollPhysics(),
      //                 itemCount: snapshot.data!.length,
      //                 itemBuilder: (context, index) {
      //                   final product = snapshot.data![index];
      //                   return ListTile(
      //                     title: Text(product['name']),
      //                     subtitle: Text('\$${product['price']}'),
      //                   );
      //                 },
      //               );
      //             }
      //           },
      //         ),
      //         const Text(
      //           'Create User',
      //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //         ),
      //         const SizedBox(height: 8),
      //         TextField(
      //           controller: usernameController,
      //           decoration: const InputDecoration(
      //             labelText: 'Username',
      //             border: OutlineInputBorder(),
      //           ),
      //         ),
      //         const SizedBox(height: 8),
      //         TextField(
      //           controller: emailController,
      //           decoration: const InputDecoration(
      //             labelText: 'Email',
      //             border: OutlineInputBorder(),
      //           ),
      //         ),
      //         const SizedBox(height: 8),
      //         TextField(
      //           controller: passwordController,
      //           obscureText: true,
      //           decoration: const InputDecoration(
      //             labelText: 'Password',
      //             border: OutlineInputBorder(),
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //         ElevatedButton(
      //           onPressed: createUser,
      //           child: const Text('Create User'),
      //         ),
      //         const Divider(height: 32, thickness: 2),
      //         const Text(
      //           'Create Order',
      //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //         ),
      //         const SizedBox(height: 8),
      //         TextField(
      //           controller: productIdController,
      //           decoration: const InputDecoration(
      //             labelText: 'Product ID',
      //             border: OutlineInputBorder(),
      //           ),
      //         ),
      //         const SizedBox(height: 8),
      //         TextField(
      //           controller: quantityController,
      //           keyboardType: TextInputType.number,
      //           decoration: const InputDecoration(
      //             labelText: 'Quantity',
      //             border: OutlineInputBorder(),
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //         ElevatedButton(
      //           onPressed: createOrder,
      //           child: const Text('Create Order'),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoginPage = true; // ログインページの表示制御

  void loginUser() async {
    // APIへのログインリクエストを送信する処理
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/login'), // 適切なAPIエンドポイントに変更
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // ログイン成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      // 次のページに遷移する処理を追加
    } else {
      // ログイン失敗
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed!')),
      );
    }
  }

  void createUser() async {
    // APIへのユーザー作成リクエストを送信する処理
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/users'), // 適切なAPIエンドポイントに変更
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': emailController.text, // 必要なフィールドを追加
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      // ユーザー作成成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully!')),
      );
      // 作成後、ログインページに遷移することもできます
    } else {
      // ユーザー作成失敗
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EC APP Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // タイトルのテキスト
            Text(
              isLoginPage ? 'Login' : 'Sign up',
              style: const TextStyle(
                fontSize: 32, // フォントサイズを少し大きく
                fontWeight: FontWeight.w700, // 太字をより強調
                color: Colors.blue, // 色
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(2.0, 2.0), // 影のオフセット
                    blurRadius: 1.0, // 影のぼかし具合
                    color: Colors.grey, // 影の色
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // タイトルとテキストフィールドの間にスペース
            if (isLoginPage) ...[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loginUser,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0), // 角を丸める
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0), // 内側の余白
                  backgroundColor: Colors.blue, // ボタンの背景色
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ), // テキストスタイル
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLoginPage = false; // ログインページに切り替え
                  });
                },
                child: const Text("Don't have an account? Create one."),
              ),
            ] else ...[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: createUser,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0), // 角を丸める
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0), // 内側の余白
                  backgroundColor: Colors.blue, // ボタンの背景色
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ), // テキストスタイル
                ),
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLoginPage = true; // ログインページに切り替え
                  });
                },
                child: const Text('Already have an account? Login.'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void createUser() async {
    // APIへのユーザー作成リクエストを送信する処理をここに追加
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/users'), // ここにAPIエンドポイントを記入
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      // ユーザー作成成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully!')),
      );
      // 作成後、ログインページなどに遷移することもできます
    } else {
      // ユーザー作成失敗
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: createUser,
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

// ユーザー一覧ページ
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  Future<List<dynamic>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.97:8080/users'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text(user['email']),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// 商品一覧ページ
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  Future<List<dynamic>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.97:8080/products'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text('\$${product['price']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// 過去の注文履歴ページ
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: Center(
        child: const Text('ここに過去の注文履歴を表示します'),
      ),
    );
  }
}

// 買い物かごページ
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: Center(
        child: const Text('ここにカートを表示します'),
      ),
    );
  }
}

// プロファイルページ
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: Center(
        child: const Text('ここにプロファイルを表示します'),
      ),
    );
  }
}

// ユーザー作成ページ
class CreateUserPage extends StatelessWidget {
  const CreateUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> createUser() async {
      final response = await http.post(
        Uri.parse('http://192.168.1.97:8080/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'role': 'user',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create user: ${response.body}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: createUser,
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}

// 注文作成ページ
class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productIdController = TextEditingController();
    final quantityController = TextEditingController();

    Future<void> createOrder() async {
      final response = await http.post(
        Uri.parse('http://192.168.1.97:8080/order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 'user-id-here',
          'products': [
            {
              'productId': productIdController.text,
              'quantity': int.parse(quantityController.text),
            },
          ],
          'totalAmount': 100.0,
          'status': 'pending',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create order: ${response.body}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: productIdController,
              decoration: const InputDecoration(labelText: 'Product ID'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: createOrder,
              child: const Text('Create Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
