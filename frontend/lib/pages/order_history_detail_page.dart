import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/order.dart';
import 'package:intl/intl.dart'; // DateFormatのために必要
import 'package:http/http.dart' as http;

import 'product_detail_page.dart';
import '../utils/config.dart';
import '../models/product.dart';

class OrderHistoryDetailPage extends StatelessWidget {
  final Order order;

  const OrderHistoryDetailPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

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
              'Order ID: ${order.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Status: ${order.status}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Total Amount: ￥${order.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Ordered At: ${order.orderedAt != null ? dateFormat.format(order.orderedAt!) : 'N/A'}',
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
                itemCount: order.orderProduct.length,
                itemBuilder: (context, index) {
                  final productData = order.orderProduct[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.shopping_cart, color: Colors.blue),
                      title: Text(
                        productData.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Quantity: ${productData.quantity}'),
                      trailing: Text(
                        '￥${(productData.product.price * productData.quantity).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // todo: tap時の詳細ページ遷移
                      onTap: () async {
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                product: productData.product,
                                showAddToCartButton: false,
                              ),
                            ),
                          );
                        } catch (e) {
                          print('Error ${e}');
                        }
                      },
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
