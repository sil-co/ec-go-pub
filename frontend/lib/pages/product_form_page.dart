import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/app_drower.dart';
import '../utils/auth_service.dart';
import '../utils/snackbar_utils.dart';
import '../components/image_upload_screen.dart';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormPage({Key? key, this.product}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _priceController.text = widget.product!['price']?.toString() ?? '';
      _stockController.text = widget.product!['stock']?.toString() ?? '';
      _categoryController.text = widget.product!['category'] ?? '';
    }
  }

  Future<void> _submitProduct() async {
    try {
      if (_formKey.currentState!.validate()) {
        final token = await authService.getToken();
        if (token == null) {
          throw Exception('No token found');
        }

        final url = widget.product == null
            ? Uri.parse('http://localhost:8080/product')
            : Uri.parse(
                'http://localhost:8080/product/${widget.product!['id']}');

        final product = {
          "name": _nameController.text,
          "description": _descriptionController.text,
          "price": double.tryParse(_priceController.text) ?? 0.0,
          "stock": int.tryParse(_stockController.text) ?? 0,
          "category": _categoryController.text,
        };

        final response = widget.product == null
            ? await http.post(
                url,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': token,
                },
                body: jsonEncode(product),
              )
            : await http.put(
                url,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': token,
                },
                body: jsonEncode(product),
              );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          showSuccessSnackbar(
              context,
              widget.product == null
                  ? "Product created successfully!"
                  : "Product updated successfully!");
          if (widget.product != null) {
            // Navigator.pop(context, product);
          } else {
            _clearForm();
          }
        } else {
          showErrorSnackbar(context,
              "Failed to ${widget.product == null ? 'create' : 'update'} product.");
        }
      }
    } catch (e) {
      print(e);
      showErrorSnackbar(context,
          'Failed to ${widget.product == null ? 'create' : 'update'} product.');
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
        title: Text(widget.product == null ? 'Create Product' : 'Edit Product'),
        leading: widget.product != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, widget.product);
                },
              )
            : null, // 新規作成の場合は表示しない
      ),
      drawer: widget.product == null
          ? const AppDrawer()
          : null, // update時はdrawerを非表示
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 画像アップロード画面をここに表示
              Text("Upload Product Image", style: TextStyle(fontSize: 18)),
              // SizedBox(height: 10),

              Container(
                height: 200, // 固定の高さを設定
                child: ImageUploadScreen(),
              ),

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
                child: Text(widget.product == null ? 'Submit' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
