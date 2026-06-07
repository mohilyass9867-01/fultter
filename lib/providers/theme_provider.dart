import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Memuat konfigurasi mode tema yang tersimpan di Hive saat aplikasi pertama kali dibuka
  void loadTheme() {
    var box = Hive.box('habits');
    _isDarkMode = box.get('isDarkMode', defaultValue: false);
    notifyListeners();
  }

  // Mengubah status tema harian dan langsung menyimpannya ke local database Hive
  void toggleTheme(bool value) {
    _isDarkMode = value;
    var box = Hive.box('habits');
    box.put('isDarkMode', value);
    notifyListeners(); // Memicu UI MaterialApp untuk rebuild ke mode gelap/terang
  }
}