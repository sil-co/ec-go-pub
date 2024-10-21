import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/app_drower.dart';

// 商品一覧ページ
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  Future<List<dynamic>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/products'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back), // 戻るアイコン
        //   onPressed: () {
        //     Navigator.pop(context); // 前のページに戻る
        //   },
        // ),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 2列で表示
                childAspectRatio: 1, // 高さと幅の比率を調整（0.5に変更）
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
                          '\$${product['price'].toStringAsFixed(2)}',
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