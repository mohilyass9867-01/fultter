import 'package:flutter/material.dart';

class AppTheme {
  // Definisi warna utama
  static const Color primaryColor = Color(0xFF6200EE); 
  static const Color backgroundColor = Color.fromARGB(255, 150, 54, 54);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    useMaterial3: true,
    // Kamu bisa tambahkan styling untuk button atau text di sini
  );

  // Kamu bisa tambahkan darkTheme di sini jika ingin
}