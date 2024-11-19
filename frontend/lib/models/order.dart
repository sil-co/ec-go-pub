import 'package:frontend/models/product.dart';

class Order {
  final String id;
  final String userId;
  final List<Product> products;
  final double totalAmount;
  final String status;
  final DateTime orderedAt;

  Order({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.orderedAt,
  });
}
