import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product_detail_page.dart';
import '../components/app_drower.dart';
import '../utils/auth_service.dart';

// 商品一覧ページ
class ProductsPage extends StatelessWidget {
  final bool isMine;
  ProductsPage({super.key, this.isMine = false});
  final AuthService authService = AuthService();

  Future<List<dynamic>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/products/all'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<dynamic>> fetchMyProducts() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse('http://localhost:8080/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );
    print(response.statusCode);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic>? products =
          jsonDecode(response.body) as List<dynamic>?;

      if (products == null) {
        return [];
      }
      return products; // ここでは非 nullable 型として扱える
    } else {
      throw Exception('Failed to load my products: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getProducts() {
    return isMine ? fetchMyProducts() : fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isMine ? 'My Products' : 'Products'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            // 配列が空の場合の処理
            return const Center(child: Text('No products available.'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 列
                childAspectRatio: 1, // 高さと幅の比率を調整
                crossAxisSpacing: 12.0, // 列間のスペース
                mainAxisSpacing: 12.0, // 行間のスペース
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                final imageUrl = product['imageUrl'] ?? 'assets/no_image.jpg';

                return Card(
                  elevation: 8, // 高さのある影を追加
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // 角を丸くする
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: SizedBox(
                          height: 120, // 高さを固定（150から120に変更）
                          child: Center(
                            child: Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // フォントサイズを少し小さく
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // テキストが長い場合に省略
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '￥${product['price'].toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12, // フォントサイズを調整
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // 下部のスペース
                      ElevatedButton(
                        onPressed: () {
                          // ここに商品の詳細ページへの遷移処理を追加
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // ボタンの色
                          foregroundColor: Colors.white, // ボタンのテキスト色
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // ボタンの角を丸く
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                      const SizedBox(height: 8),
                      if (isMine) ...[
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Editボタンの処理
                          },
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen, // ボタンの背景色
                            foregroundColor: Colors.white, // テキストとアイコンの色
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // 丸みを追加
                            ),
                            elevation: 5, // 影を追加
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Deleteボタンの処理
                          },
                          icon: const Icon(Icons.delete, size: 20),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // ボタンの背景色
                            foregroundColor: Colors.white, // テキストとアイコンの色
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // 丸みを追加
                            ),
                            elevation: 5, // 影を追加
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Add to Cartボタンの処理
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 20),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // ボタンの背景色
                            foregroundColor: Colors.white, // テキストとアイコンの色
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // 丸みを追加
                            ),
                            elevation: 5, // 影を追加
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
