import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/auth_service.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];
  final String apiUrl = 'http://localhost:8080/cart';
  final AuthService authService = AuthService();

  List<Map<String, dynamic>> get cartItems => _cartItems;

  Future<void> addToCart(Map<String, dynamic> product) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      // APIにカートを追加
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token, // 適切なユーザーIDを使用
          'products': [
            {
              'productId': product['id'], // 商品IDを指定
              'quantity': 1 // 数量を指定
            }
          ],
        }),
      );

      if (response.statusCode == 201) {
        // カートへの追加成功
        _cartItems.add(product);
        notifyListeners(); // リスナーに通知してUIを更新
      } else {
        // エラー処理
        throw Exception('Failed to add to cart');
      }
    } catch (e) {
      // エラーメッセージをログに出力
      print('Error adding to cart: $e');
      throw e; // エラーを再スロー
    }
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  int get itemCount => _cartItems.length;

  void fetchCart(String userId) async {
    final response = await http.get(Uri.parse('$apiUrl?userId=$userId'));

    if (response.statusCode == 200) {
      final cartData = jsonDecode(response.body);
      _cartItems.clear(); // 既存のアイテムをクリア
      for (var product in cartData['products']) {
        _cartItems.add({
          'id': product['productId'],
          'quantity': product['quantity'],
        });
      }
      notifyListeners(); // UIを更新
    } else {
      // エラー処理
      throw Exception('Failed to load cart');
    }
  }
}
