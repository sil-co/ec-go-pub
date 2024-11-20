import 'package:frontend/models/product.dart';

class Order {
  final String id;
  final List<OrderProduct> orderProduct;
  final double totalAmount;
  final String status;
  final DateTime? orderedAt;

  Order({
    required this.id,
    required this.orderProduct,
    required this.totalAmount,
    required this.status,
    this.orderedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderProduct: (json['orderProduct'] as List<dynamic>)
          .map((orderProductJson) => OrderProduct.fromJson(orderProductJson))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      orderedAt: DateTime.parse(json['orderedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderProduct':
          orderProduct.map((orderProduct) => orderProduct.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderedAt': orderedAt?.toUtc().toIso8601String(),
    };
  }
}

class OrderProduct {
  final Product product;
  final int quantity;

  OrderProduct({
    required this.product,
    required this.quantity,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
