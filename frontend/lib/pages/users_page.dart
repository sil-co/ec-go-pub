import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/app_drower.dart';

// ユーザー一覧ページ
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:8080/users'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text(user['email']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
