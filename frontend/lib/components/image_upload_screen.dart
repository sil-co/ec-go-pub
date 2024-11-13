import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  io.File? _imageFile;
  Uint8List? _webImage;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Webの場合、Uint8Listとして画像データを読み込む
        _webImage = await pickedFile.readAsBytes();
      } else {
        // モバイルアプリの場合、Fileとして画像を読み込む
        _imageFile = io.File(pickedFile.path);
      }
      setState(() {}); // UIを更新
    } else {
      print('No image selected.');
    }
  }

  Future uploadImage() async {
    // アップロード処理
    if (kIsWeb && _webImage != null) {
      // Webでのアップロード処理
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8080/image'),
      );

      // Uint8ListからMultipartFileを作成
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          _webImage!,
          filename: 'uploaded_image.jpg', // 任意のファイル名を指定
        ),
      );

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final res = await http.Response.fromStream(response);
          final json = jsonDecode(res.body);
          print("Image uploaded: ${json['url']}");
        } else {
          print("Failed to upload image: ${response.statusCode}");
        }
      } catch (e) {
        print("Error during upload: $e");
      }
    } else if (_imageFile != null) {
      // モバイルアプリでのアップロード処理（参考）
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8080/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final res = await http.Response.fromStream(response);
          final json = jsonDecode(res.body);
          print("Image uploaded: ${json['url']}");
        } else {
          print("Failed to upload image: ${response.statusCode}");
        }
      } catch (e) {
        print("Error during upload: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 画像表示部分
          Container(
            width: 250,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.contain)
                : _webImage != null
                    ? Image.memory(_webImage!, fit: BoxFit.contain)
                    : Icon(Icons.camera_alt, size: 60, color: Colors.grey),
          ),
          SizedBox(width: 20),

          // ボタンを縦に並べる
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Pick Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Upload Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
