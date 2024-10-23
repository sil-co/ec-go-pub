import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'provider/cart_provider.dart';
import 'utils/auth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService authService = AuthService();
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await authService.getToken(); // トークンを取得
    if (token != null) {
      final loggedIn = await authService.checkAuth(token); // 認証確認
      setState(() {
        isLoggedIn = loggedIn; // 認証状態を反映
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      // ローディング中
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (isLoggedIn!) {
      // 認証済みならHomePageへ
      return const HomePage();
    } else {
      // 未認証ならLoginPageへ
      authService.logout();
      return const LoginPage();
    }
  }
}
