import 'package:flutter/material.dart';

import '../utils/auth_service.dart';
import 'login_page.dart';
import 'product_page.dart';
import '../components/app_drower.dart';
import 'cart_page.dart';
import 'order_history_page.dart';
import 'user_profile_page.dart';
import 'users_page.dart';
import 'intro_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(color: Colors.blue),
      //         child: Text(
      //           'EC App Menu',
      //           style: TextStyle(color: Colors.white, fontSize: 24),
      //         ),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.shopping_cart),
      //         title: const Text('Products'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => const ProductsPage()),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.shopping_basket),
      //         title: const Text('Cart'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => const CartPage()),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.history),
      //         title: const Text('Order History'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (context) => const OrderHistoryPage()),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.person),
      //         title: const Text('Profile'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (context) => const UserProfilePage()),
      //           );
      //         },
      //       ),
      //       const Divider(), // Divider to separate menu items
      //       ListTile(
      //         leading: const Icon(Icons.logout),
      //         title: const Text('Logout'),
      //         onTap: () async {
      //           await authService.logout();
      //           Navigator.pushReplacement(
      //             context,
      //             MaterialPageRoute(builder: (context) => const LoginPage()),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.people),
      //         title: const Text('Users'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => const UsersPage()),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      drawer: const AppDrawer(),
      body: const Center(
        child: const IntroPage(),
      ),
    );
  }
}
