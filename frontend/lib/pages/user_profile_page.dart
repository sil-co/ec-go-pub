import 'package:flutter/material.dart';

import '../components/app_drower.dart';

// プロファイルページ
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: const Text('ここにプロファイルを表示します'),
      ),
    );
  }
}
