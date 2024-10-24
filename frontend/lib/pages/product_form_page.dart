import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../components/app_drower.dart';
import '../utils/auth_service.dart';
import '../utils/snackbar_utils.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  // 各フィールド用コントローラー
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final AuthService authService = AuthService();

  Future<void> _submitProduct() async {
    try {
      if (_formKey.currentState!.validate()) {
        final token = await authService.getToken();
        if (token == null) {
          throw Exception('No token found');
        }

        final url = Uri.parse('http://localhost:8080/product');
        final product = {
          "name": _nameController.text,
          "description": _descriptionController.text,
          "price": double.tryParse(_priceController.text) ?? 0.0,
          "stock": int.tryParse(_stockController.text) ?? 0,
          "category": _categoryController.text,
        };

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: jsonEncode(product),
        );

        if (response.statusCode == 201) {
          showSuccessSnackbar(context, "Product created successfully!");
          _clearForm();
        } else {
          Fluttertoast.showToast(msg: "Failed to create product.");
        }
      }
    } catch (e) {
      print(e);
      showErrorSnackbar(context, 'Failed to create.');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _categoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back), // 戻るアイコン
        //   onPressed: () {
        //     Navigator.pop(context); // 前のページに戻る
        //   },
        // ),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter product name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null
                        ? 'Enter valid price'
                        : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || int.tryParse(value) == null
                        ? 'Enter valid stock'
                        : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
