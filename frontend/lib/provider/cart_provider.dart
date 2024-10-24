import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/auth_service.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];
  final String cartsApiUrl = 'http://localhost:8080/carts';
  final String cartApiUrl = 'http://localhost:8080/cart';
  final AuthService authService = AuthService();

  List<Map<String, dynamic>> get cartItems => _cartItems;

  Future<void> addToCart(Map<String, dynamic> product) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final products = {
      'productId': product['id'], // 商品IDを指定
      'quantity': 1 // 数量を指定
    };

    // APIにカートを追加
    final response = await http.post(
      Uri.parse(cartApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode(products),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // カートへの追加成功
      // _cartItems.add(product);
      await getCarts();
      notifyListeners(); // リスナーに通知してUIを更新
    } else {
      // エラー処理
      throw Exception('Failed to add to cart');
    }
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  int get itemCount => _cartItems.length;

  Future<void> getCarts() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    // final response = await http.get(Uri.parse('$cartApiUrl?userId=$userId'));
    final response = await http.get(Uri.parse(cartsApiUrl), headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final productData = jsonDecode(response.body);
      _cartItems.clear(); // 既存のアイテムをクリア
      // productData が空の場合、何も追加せずにreturn
      if (productData is! List || productData.isEmpty) {
        notifyListeners(); // UIを更新
        return;
      }
      // productDetailsが返ってきた場合の処理
      for (var product in productData) {
        _cartItems.add({
          'id': product['productID'], // カートに登録されている商品のID
          'quantity': product['quantity'], // カートに登録されている商品の数量
          'name': product['name'], // 商品名
          'description': product['description'], // 商品の説明
          'price': product['price'], // 商品の価格
          'stock': product['stock'], // 在庫数
        });
      }
      notifyListeners(); // UIを更新
    } else {
      // エラー処理
      throw Exception('Failed to load cart');
    }
  }
}
