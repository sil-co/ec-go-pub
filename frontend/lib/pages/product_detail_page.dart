import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'package:provider/provider.dart';

import '../provider/cart_provider.dart';
import '../utils/snackbar_utils.dart';
import '../utils/config.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // final imageUrl = (product['image'] != null &&
    //         product['image']['Path'] != null &&
    //         product['image']['Path'].isNotEmpty)
    //     ? '${Config.apiUrl}/${product['image']['Path']}'
    //     : 'assets/no_image.jpg';

    final imageUrl = product.image?.path?.isNotEmpty == true
        ? '${Config.apiUrl}/${product.image!.path}'
        : 'assets/no_image.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            // Center the entire column
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Align column items in the center
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 8),
                Text(
                  '￥${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 16),
                Text(
                  product.description ?? 'No description available.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    // Handle the add to cart action
                    try {
                      await Provider.of<CartProvider>(context, listen: false)
                          .addToCart(product);
                      showSuccessSnackbar(context, 'Added to Cart');
                    } catch (e) {
                      showErrorSnackbar(context, 'Failed to add to cart');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal:
                            30), // Adjust padding for a better button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
