import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/auth_service.dart';
import '../utils/snackbar_utils.dart';
import 'login_page.dart';
import '../components/app_drower.dart';
import 'intro_page.dart';
import '../provider/cart_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? cart;
  bool isLoading = true; // ローディング状態の管理

  @override
  void initState() {
    super.initState();
    getCartData(); // カートの取得を初期化時に呼び出す
  }

  Future<void> getCartData() async {
    try {
      await Provider.of<CartProvider>(context, listen: false).getCarts();
      setState(() {
        isLoading = false; // 状態を更新するために setState を呼び出す
      });
    } catch (e) {
      print('Error getting cart data: $e');
      showErrorSnackbar(context, 'Error getting cart data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // ローディング表示
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: const IntroPage(),
      ),
    );
  }
}
