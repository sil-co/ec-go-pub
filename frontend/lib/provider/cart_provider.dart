import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/auth_service.dart';
import '../utils/config.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];
  final String cartsApiUrl = '${Config.apiUrl}/carts';
  final String cartApiUrl = '${Config.apiUrl}/cart';
  final AuthService authService = AuthService();

  List<Map<String, dynamic>> get cartItems => _cartItems;

  Future<void> addToCart(Product product) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final products = {
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
      body: jsonEncode(products),
    );

    print(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // カートへの追加成功
      await getCarts();
      notifyListeners(); // リスナーに通知してUIを更新
    } else {
      print(response.statusCode);
      // エラー処理
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> removeFromCart(Map<String, dynamic> productData) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      // クエリパラメータに商品IDと数量を追加
      final url = Uri.parse(
          '$cartApiUrl?productId=${productData['product'].id}&quantity=${productData['quantity']}');

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
      _cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

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
      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is! Map<String, dynamic>) {
        throw Exception('Unexpected response format');
      }

      final cartData = decodedResponse;

      _cartItems.clear(); // 既存のアイテムをクリア

      // productsリストを取得
      final products = cartData['products'];
      if (products is! List) {
        notifyListeners(); // UIを更新
        return; // productsがリストでなければ終了
      }

      for (var productEntry in products) {
        if (productEntry is! Map<String, dynamic>) {
          continue; // productEntryがMapでなければスキップ
        }

        final product = productEntry['product'];
        if (product is! Map<String, dynamic>) {
          continue; // productがMapでなければスキップ
        }

        final productData = Product.fromJson(product);

        _cartItems.add({
          'product': productData, // Productオブジェクトをそのまま追加
          'quantity': productEntry['quantity'], // カートに登録されている数量
        });

        // _cartItems.add({
        //   'productId': product['id'], // 商品ID
        //   'quantity': productEntry['quantity'], // カートに登録されている数量
        //   'name': product['name'], // 商品名
        //   'description': product['description'], // 商品説明
        //   'price': product['price'], // 商品価格
        //   'stock': product['stock'], // 在庫数
        //   'image': product['image'], // 商品画像 (必要なら)
        // });
      }
      notifyListeners(); // UIを更新
    } else {
      // エラー処理
      throw Exception('Failed to load cart');
    }
  }
}
