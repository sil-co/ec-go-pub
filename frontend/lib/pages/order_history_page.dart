import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting dates.

import '../components/app_drower.dart';
import '../utils/auth_service.dart';
import 'order_history_detail_page.dart';

// Order model to parse API response
class Order {
  final String id;
  final List<dynamic> products;
  final double totalAmount;
  final String status;
  final DateTime orderedAt;

  Order({
    required this.id,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.orderedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      products: json['products'],
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      // orderedAt: DateTime.parse(json['orderedAt']['\$date']),
      orderedAt: DateTime.parse(json['orderedAt']),
    );
  }
}

// OrderHistoryPage widget
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<Order>> _futureOrders;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _futureOrders = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final url = 'http://localhost:8080/orders';

    try {
      // final response = await http.get(url);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic>? data = jsonDecode(response.body);

        if (data == null || data.isEmpty) {
          return [];
        }

        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      throw Exception('Error fetching orders: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Order>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

// Card widget to display each order
class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm(); // Format date and time.

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text('Status: ${order.status}'),
            const SizedBox(height: 8.0),
            Text('Total Amount: ￥${order.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 8.0),
            Text('Ordered At: ${dateFormat.format(order.orderedAt)}'),
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                print('Order ID: ${order.id}');
                print('Status: ${order.status}');
                print('Total Amount: ${order.totalAmount}');
                print('Ordered At: ${order.orderedAt}');
                print('Products: ${order.products}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryDetailPage(
                      orderId: order.id.toString(),
                      status: order.status,
                      totalAmount: order.totalAmount,
                      orderedAt: order.orderedAt,
                      products: order.products.map((product) {
                        return {
                          'name': product['product']['name'],
                          'quantity': product['quantity'],
                          'price': product['product']['price']
                        };
                      }).toList(),
                    ),
                  ),
                );
              },
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  String getProductNameById(String productID) {
    return "Product Name for $productID"; // 実際には商品名を返す
  }
}
