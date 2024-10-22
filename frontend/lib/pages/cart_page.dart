import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/cart_provider.dart';
import '../components/app_drower.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.cartItems;

    double getTotalAmount() {
      return cartItems.fold(0, (sum, item) => sum + item['price']);
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
                    itemCount: cart.itemCount,
                    itemBuilder: (context, index) {
                      final product = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Image.asset(
                            product['imageUrl'] ?? 'assets/no_image.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            product['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            '\$${product['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.green, fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              cart.removeFromCart(product);
                            },
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
                        '\$${getTotalAmount().toStringAsFixed(2)}',
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
                    onPressed: () {
                      // 購入処理のロジックを追加
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Order Confirmed'),
                          content: const Text('Thank you for your purchase!'),
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
}
