import 'package:flutter/material.dart';
import '../../pages/home_page.dart'; // Pastikan path ini sesuai dengan lokasi file home_page.dart kamu

class AppRoutes {
  static const String home = '/';
  // static const String addHabit = '/add-habit'; // Kamu bisa uncomment ini jika nanti buat halaman tambah

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      // addHabit: (context) => AddHabitPage(),
    };
  }
}