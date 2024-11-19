import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormatのために必要
import 'package:http/http.dart' as http;

import 'product_detail_page.dart';
import '../utils/config.dart';
import '../models/product.dart';

class OrderHistoryDetailPage extends StatelessWidget {
  final String orderId;
  final String status;
  final double totalAmount;
  final DateTime orderedAt;
  final List<Map<String, dynamic>> products; // 商品のリストを受け取る

  const OrderHistoryDetailPage({
    Key? key,
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.orderedAt,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    Future<Map<String, dynamic>> getProduct(String productID) async {
      print(productID);
      final response = await http.get(Uri.parse(
          '${Config.apiUrl}/product/${productID}')); // 適切なURLに変更してください
      if (response.statusCode == 200) {
        final Map<String, dynamic> productData = jsonDecode(response.body);

        // productDataが空でないか確認し、Mapを返す
        if (productData.isNotEmpty) {
          return productData;
        } else {
          throw Exception('Product data is empty');
        }
      } else {
        throw Exception('Failed to load product');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Status: $status',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Total Amount: ￥${totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Ordered At: ${dateFormat.format(orderedAt)}',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12.0),
            const Text(
              'Products:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.shopping_cart, color: Colors.blue),
                      title: Text(
                        product['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Quantity: ${product['quantity']}'),
                      trailing: Text(
                        '￥${(product['price'] * product['quantity']).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // todo: tap時の詳細ページ遷移
                      // onTap: () async {
                      //   try {
                      //     final productData = await getProduct(product['id']);
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) =>
                      //             ProductDetailPage(product: productData),
                      //       ),
                      //     );
                      //   } catch (e) {
                      //     print('Error ${e}');
                      //   }
                      // },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
