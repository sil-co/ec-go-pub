import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/models/product.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../provider/cart_provider.dart';
import '../components/app_drower.dart';
import '../utils/auth_service.dart';
import '../utils/config.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final cartItems = cart.cartItems;

    double getTotalAmount() {
      double total = cartItems.fold(0.0, (sum, item) {
        // 商品のリストの最初のアイテムを使って価格を取得
        double price = item.product.price;
        int quantity = item.quantity;
        return sum + (price * quantity);
      });
      return total.ceilToDouble(); // 合計を切り上げ
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      drawer: const AppDrawer(),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'My cart is empty!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.itemLength,
                    itemBuilder: (context, index) {
                      final productData = cartItems[index];
                      final imageUrl = (productData
                                  .product.image?.path?.isNotEmpty ??
                              false)
                          ? '${Config.apiUrl}/${productData.product.image?.path}'
                          : 'assets/no_image.jpg';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Container(
                            // コンテナでラップする
                            width: 100, // 幅を固定
                            height: 100, // 高さを固定
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    imageUrl), // AssetImage -> NetworkImageに変更
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          subtitle: Column(
                            // RowからColumnに変更
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productData.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                // 価格と数量をRowで横並びに
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '￥${productData.product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10), // スペースを追加
                                  Text(
                                    'Quantity: ${productData.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey, // 色を変えて目立たなくする
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, // Rowのサイズを最小限に
                            children: [
                              // Todo: 増減処理
                              // IconButton(
                              //   icon:
                              //       const Icon(Icons.remove, color: Colors.red),
                              //   onPressed: () {
                              //     // 数量を減らす処理
                              //     // cart.decreaseQuantity(productData);
                              //   },
                              // ),
                              // IconButton(
                              //   icon:
                              //       const Icon(Icons.add, color: Colors.green),
                              //   onPressed: () {
                              //     // 数量を増やす処理
                              //     // cart.increaseQuantity(productData);
                              //   },
                              // ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  // 商品をカートから削除する処理
                                  cart.removeFromCart(productData);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '￥${getTotalAmount().toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // 購入処理のロジックを追加
                      // Todo: Stripe処理を追加
                      final order = Order(
                          id: '', // サーバーで自動生成される場合は空文字列を使用
                          totalAmount: getTotalAmount(),
                          status: 'Pending',
                          // orderedAt: DateTime.now(),
                          // orderedAt: DateTime.now().toUtc(),
                          orderProduct: cartItems);
                      final submitStatus = await submitOrder(order);
                      if (submitStatus) {
                        await cart.deleteCarts();
                        _showConfirmationDialog(
                            context, 'Thank you for your purchase!');
                      } else {
                        _showErrorDialog(context, 'Failed to place order.');
                      }
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Proceed to Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

// カートアイテムから必要な情報を抽出する関数
  List<Map<String, dynamic>> getProductsForOrder(
      List<Map<String, dynamic>> cartItems) {
    return cartItems.map((productData) {
      return {
        'productId': productData['product'].id, // productIdのみ
        'quantity': productData['quantity'], // quantityのみ
      };
    }).toList();
  }

  Future<bool> submitOrder(Order order) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    const url = '${Config.apiUrl}/order';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token, // Attach JWT token in the header.
    };

    try {
      final encodedJson = jsonEncode(order);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: encodedJson,
      );
      return response.statusCode < 300 && response.statusCode >= 200;
    } catch (e) {
      return false;
    }
  }

  void _showConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Confirmed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
