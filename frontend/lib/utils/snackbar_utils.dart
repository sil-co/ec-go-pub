import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center, // テキストを左右中央揃え
      ),
      duration: const Duration(seconds: 3), // 表示時間を設定
      backgroundColor: const Color.fromARGB(255, 254, 0, 0), // 背景色を赤に設定
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center, // テキストを左右中央揃え
      ),
      duration: const Duration(seconds: 3), // 表示時間を設定
      backgroundColor: const Color.fromARGB(255, 0, 198, 102), // 背景色を緑に設定
      behavior: SnackBarBehavior.floating, // スナックバーを浮かせる
    ),
  );
}
