import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3), // 表示時間を設定
      backgroundColor: Colors.redAccent, // 背景色を赤に設定
    ),
  );
}
