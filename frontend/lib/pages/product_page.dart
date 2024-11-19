import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../provider/cart_provider.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';
import '../components/app_drower.dart';
import '../utils/snackbar_utils.dart';
import '../utils/auth_service.dart';
import '../utils/config.dart';
import '../models/product.dart';

// 商品一覧ページ
class ProductsPage extends StatefulWidget {
  final bool isMine; // isMine フィールドを追加

  // コンストラクタで初期値を設定
  const ProductsPage({super.key, required this.isMine});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _productsFuture;
  @override
  void initState() {
    super.initState();
    _productsFuture = getAllOrMyProducts(); // 初回データ取得
  }

  // final bool isMine;
  // ProductsPage({super.key, this.isMine = false});
  final AuthService authService = AuthService();
  // 共通のボタンスタイル
  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent, // ボタンの色（デフォルト）
    foregroundColor: Colors.white, // ボタンのテキスト色
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // ボタンの角を丸く
    ),
    minimumSize: const Size(150, 40), // ボタンの最小サイズ
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // パディング
  );

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/products/all'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> getMyProducts() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('${Config.apiUrl}/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // JSONデコード結果をリストに変換
      final List<dynamic> jsonList = jsonDecode(response.body);
      // List<dynamic>をList<Product>に変換
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load my products: ${response.statusCode}');
    }
  }

  Future<List<Product>> getAllOrMyProducts() {
    return widget.isMine ? getMyProducts() : getProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = getAllOrMyProducts(); // 再取得
    });
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) {
      return 5; // PC
    } else if (width >= 960) {
      return 4; // PC
    } else if (width >= 600) {
      return 3; // タブレット
    } else if (width >= 350) {
      return 2; // モバイル
    } else {
      return 1; // SE
    }
  }

  double _getItemHeight(double height, int crossAxisCount) {
    final availableHeight =
        height - (10.0 * (crossAxisCount - 1)); // 行間のスペースを引く
    return availableHeight / crossAxisCount; // アイテムの高さを決定
  }

  Future<void> deleteProduct(product) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('${Config.apiUrl}/product/${product!.id}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(product),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showSuccessSnackbar(context, "Product delete successfully!");
      } else {
        showErrorSnackbar(context, "Failed to Delete product.");
      }
    } catch (e) {
      print(e);
      showErrorSnackbar(context, 'Failed to Delete product.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isMine ? 'My Products' : 'Products'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            // 配列が空の場合の処理
            return const Center(child: Text('No products available.'));
          } else {
            return LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = _getCrossAxisCount(width);

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final product = snapshot.data![index];

                  final imageUrl = product.image?.path?.isNotEmpty == true
                      ? '${Config.apiUrl}/${product.image!.path}'
                      : 'assets/no_image.jpg';

                  return Container(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3, // 画像に多めのスペースを割り当て
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1, // タイトルにスペースを割り当て
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1, // 値段にスペースを割り当て
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '￥${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8), // 下部のスペース
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailPage(product: product),
                                  ),
                                );
                              },
                              style: buttonStyle.copyWith(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.blueAccent),
                              ),
                              child: const Text('View Details'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.isMine) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Editボタンの処理: productをProductFormPageに渡して画面遷移
                                  final updatedProduct = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductFormPage(
                                        product: product, // 編集するproductデータを渡す
                                      ),
                                    ),
                                  );
                                  // 戻り値がある場合は、リストを更新するなどの処理を行う
                                  if (updatedProduct != null) {
                                    _refreshProducts();
                                  }
                                },
                                icon: const Icon(Icons.edit, size: 20),
                                label: const Text('Edit'),
                                style: buttonStyle.copyWith(
                                  backgroundColor: WidgetStateProperty.all(
                                      Colors.lightGreen),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Deleteボタンの処理: 確認ダイアログを表示
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this product?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // ダイアログを閉じる
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context)
                                                  .pop(); // ダイアログを閉じる
                                              await deleteProduct(
                                                  product); // 製品を削除する処理を呼び出す
                                              _refreshProducts();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete, size: 20),
                                label: const Text('Delete'),
                                style: buttonStyle.copyWith(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.red),
                                ),
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await Provider.of<CartProvider>(context,
                                            listen: false)
                                        .addToCart(product);
                                    showSuccessSnackbar(
                                        context, 'Added to Cart');
                                  } catch (e) {
                                    print(e);
                                    showErrorSnackbar(
                                        context, 'Failed to add to cart');
                                  }
                                },
                                icon: const Icon(Icons.add_shopping_cart,
                                    size: 20),
                                label: const Text('Add to Cart'),
                                style: buttonStyle.copyWith(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.orange),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
          }
        },
      ),
    );
  }
}
