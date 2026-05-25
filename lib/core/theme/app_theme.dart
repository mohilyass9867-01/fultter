import 'package:flutter/material.dart';

class AppTheme {
  // Definisi warna utama
  static const Color primaryColor = Color.fromARGB(255, 177, 242, 127); 
  static const Color backgroundColor = Color.fromARGB(255, 235, 209, 117);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    useMaterial3: true,
    // Kamu bisa tambahkan styling untuk button atau text di sini
  );

  // Kamu bisa tambahkan darkTheme di sini jika ingin
}