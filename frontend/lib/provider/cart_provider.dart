import 'package:flutter/material.dart';
import 'package:frontend/models/order.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/auth_service.dart';
import '../utils/config.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<OrderProduct> _cartItems = [];
  List<OrderProduct> get cartItems => _cartItems;
  final String cartsApiUrl = '${Config.apiUrl}/carts';
  final String cartApiUrl = '${Config.apiUrl}/cart';
  final AuthService authService = AuthService();

  Future<void> addToCart(Product product) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final cartProducts = {
      'product': product.toJson(), // 商品IDを指定
      'quantity': 1 // 数量を指定
    };

    // APIにカートを追加
    final response = await http.post(
      Uri.parse(cartApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode(cartProducts),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // カートへの追加成功
      await getCarts();
      notifyListeners(); // リスナーに通知してUIを更新
    } else {
      // エラー処理
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> removeFromCart(OrderProduct productData) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      // クエリパラメータに商品IDと数量を追加
      final url = Uri.parse(
          '$cartApiUrl?productId=${productData.product.id}&quantity=${productData.quantity}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await getCarts();
        notifyListeners();
      } else {
        throw Exception('Failed to remove from cart');
      }
    } catch (e) {
      throw Exception('Failed to remove from cart');
    }
  }

  Future<void> deleteCarts() async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('$cartsApiUrl'); // カートを全削除するエンドポイント
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await getCarts(); // カートを更新
        notifyListeners(); // UI更新
      } else {
        throw Exception('Failed to clear cart');
      }
    } catch (e) {
      throw Exception('Failed to clear cart');
    }
  }

  int get itemLength => _cartItems.length;

  int get itemCount =>
      _cartItems.fold<int>(0, (sum, item) => sum + (item.quantity));

  Future<void> getCarts() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(Uri.parse(cartsApiUrl), headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final cartData = jsonDecode(response.body);

      if (cartData is! Map<String, dynamic>) {
        throw Exception('Unexpected response format');
      }

      _cartItems.clear(); // 既存のアイテムをクリア

      // productsリストを取得
      final cartProducts = cartData['cartProduct'];
      if (cartProducts is! List) {
        notifyListeners(); // UIを更新
        return; // productsがリストでなければ終了
      }

      for (var productEntry in cartProducts) {
        if (productEntry is! Map<String, dynamic>) {
          continue; // productEntryがMapでなければスキップ
        }

        final product = productEntry['product'];
        if (product is! Map<String, dynamic>) {
          continue; // productがMapでなければスキップ
        }

        final productData = Product.fromJson(product);

        // OrderProductのインスタンスを作成して_cartItemsに追加
        final orderProduct = OrderProduct(
          product: productData, // Productのリストを作成
          quantity: productEntry['quantity'],
        );

        _cartItems.add(orderProduct);
      }

      notifyListeners(); // UIを更新
    } else {
      // エラー処理
      throw Exception('Failed to load cart');
    }
  }
}
