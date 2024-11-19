import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config.dart';
import '../utils/auth_service.dart';

class ImageUploadScreen extends StatefulWidget {
  final String? initialImageUrl; // 初期画像URLを受け取る

  ImageUploadScreen({Key? key, this.initialImageUrl}) : super(key: key);

  @override
  ImageUploadScreenState createState() => ImageUploadScreenState();
}

class ImageUploadScreenState extends State<ImageUploadScreen> {
  io.File? _imageFile;
  Uint8List? _webImage;
  Uint8List? _initialImage;
  String? _imageId;
  final picker = ImagePicker();
  final AuthService authService = AuthService();
  bool isUploading = false; // アップロード中かどうか
  bool isUploaded = false; // アップロードが成功したかどうか

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrl != null) {
      _loadInitialImage(widget.initialImageUrl!); // 初期画像を読み込む
    }
  }

  Future<void> _loadInitialImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _initialImage = response.bodyBytes; // 初期画像をセット
        });
      }
    } catch (e) {
      print("Failed to load initial image: $e");
    }
  }

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
    setState(() {
      isUploading = true;
    });

    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    // アップロード処理
    if (kIsWeb && _webImage != null) {
      // Webでのアップロード処理
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiUrl}/image'),
      );

      // ヘッダーにJWTトークンを追加
      request.headers.addAll({
        'Authorization': token, // トークンを追加
        'Content-Type': 'multipart/form-data', // 必要に応じて追加
      });

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
          _imageId = json['id'];
          showSuccessSnackbar(context, "Image upload successfully!");
          setState(() {
            isUploaded = true;
          });
        } else {
          print("Failed to upload image: ${response.statusCode}");
        }
      } catch (e) {
        print("Error during upload: $e");
      } finally {
        setState(() {
          isUploading = false;
        });
      }
    } else if (_imageFile != null) {
      // モバイルアプリでのアップロード処理（参考）
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiUrl}/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final res = await http.Response.fromStream(response);
          final json = jsonDecode(res.body);
          print("Image uploaded: ${json['id']}");
        } else {
          print("Failed to upload image: ${response.statusCode}");
        }
      } catch (e) {
        print("Error during upload: $e");
      }
    }
  }

  String? getImageId() {
    return _imageId; // 画像IDを取得
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // double width = constraints.maxWidth;
          double screenWidth = MediaQuery.of(context).size.width;

          List<Widget> buildChildren() {
            return [
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
                        : _initialImage != null
                            ? Image.memory(_initialImage!, fit: BoxFit.contain)
                            : Icon(Icons.camera_alt,
                                size: 60, color: Colors.grey),
                // : Icon(Icons.camera_alt, size: 60, color: Colors.grey),
              ),
              SizedBox(width: 20),
              SizedBox(height: 15),
              // ボタンを縦に並べる
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200, // 横幅を指定
                    child: ElevatedButton(
                      onPressed: isUploading || isUploaded ? null : pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isUploaded
                            ? "Uploaded"
                            : (isUploading ? "Uploading..." : "Pick Image"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 200, // 横幅を指定
                    child: ElevatedButton(
                      onPressed: isUploading || isUploaded ? null : uploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isUploaded
                            ? "Uploaded"
                            : (isUploading ? "Uploading..." : "Upload Image"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ];
          }

          return screenWidth >= 600
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildChildren())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildChildren());
        },
      ),
    );
  }
}
