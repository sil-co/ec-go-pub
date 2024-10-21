import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/app_drower.dart';
import '../utils/auth_service.dart';
import 'package:flutter/foundation.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderProduct> products;
  final double totalAmount;
  final String status;
  final DateTime orderedAt;

  Order({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.orderedAt,
  });
}

class OrderProduct {
  final String productId;
  final int quantity;

  OrderProduct({
    required this.productId,
    required this.quantity,
  });
}

// 買い物かごページ
class CartPage extends StatelessWidget {
  // final String username;
  // final String token;

  // const CartPage({super.key, required this.username, required this.token});
  const CartPage({super.key});

  // Future<void> _checkAuthentication(BuildContext context) async {
  //   final AuthService authService = AuthService();
  //   bool isAuthenticated = await authService.checkAuth(username, token);
  //   if (!isAuthenticated) {
  //     Navigator.pushReplacementNamed(context, '/login');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // _checkAuthentication(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: const Text('ここにカートを表示します'),
      ),
    );
  }
}
