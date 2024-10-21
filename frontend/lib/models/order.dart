import 'package:flutter/foundation.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderProduct> products;
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

class OrderProduct {
  final String productId;
  final int quantity;

  OrderProduct({
    required this.productId,
    required this.quantity,
  });
}
