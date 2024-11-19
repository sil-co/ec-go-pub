import './image.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imageID;
  final Image? image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageID,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      category: json['category'],
      imageID: json['imageID'],
      // imageが存在すればImageオブジェクトを作成
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'imageID': imageID,
      'image': image?.toJson(),
    };
  }
}
