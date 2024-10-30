import 'package:flutter/material.dart';
import 'package:frontend/pages/product_edit_page.dart';
import 'package:provider/provider.dart';

import '../provider/cart_provider.dart';
import '../utils/auth_service.dart';
import '../pages/login_page.dart';
import '../pages/product_page.dart';
import '../pages/cart_page.dart';
import '../pages/order_history_page.dart';
import '../pages/user_profile_page.dart';
import '../pages/users_page.dart';
import '../pages/product_form_page.dart';
import '../pages/product_edit_page.dart';

// Drawerコンポーネント
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final cartProvider = Provider.of<CartProvider>(context);
    final List<Map<String, dynamic>> products = [
      {
        'id': '6719cbea355e6ae72afe6916',
        'name': 'Smartphone',
        'description': 'Latest model with high specs',
        'price': 699.99,
        'stock': 50,
        'category': 'Electronics',
      },
      {
        'id': '1234567890abcdef',
        'name': 'Laptop',
        'description': 'Lightweight and powerful',
        'price': 1299.99,
        'stock': 30,
        'category': 'Computers',
      },
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'EC App Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('All Products'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProductsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list), // ここでアイコンを指定
            title: const Text('My Products'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductsPage(isMine: true)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Listing'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductFormPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Cart'),
            trailing: Chip(
              // アイテム数を表示するためのChipウィジェット
              label: Text(
                '${cartProvider.itemCount}', // カートのアイテム数
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red, // Chipの背景色を設定
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrderHistoryPage()),
              );
            },
          ),
          // Todo: Profile page
          // ListTile(
          //   leading: const Icon(Icons.person),
          //   title: const Text('Profile'),
          //   onTap: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const UserProfilePage()),
          //     );
          //   },
          // ),
          const Divider(), // Divider to separate menu items
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          // Todo: Users Page (For administrators)
          // ListTile(
          //   leading: const Icon(Icons.people),
          //   title: const Text('Users'),
          //   onTap: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => const UsersPage()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
