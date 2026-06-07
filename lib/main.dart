import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/habit_provider.dart';
import 'pages/main_navigation.dart';
import 'models/habit.dart';
import 'services/notification_service.dart'; // Import layanan notifikasi baru

void main() async {
  // Memastikan binding framework siap sebelum menjalankan fungsi async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inisialisasi Hive lokal untuk Flutter
  await Hive.initFlutter();
  
  // 2. Registrasi Adapter Habit jika belum terdaftar
  if (!Hive.isAdapterRegistered(HabitAdapter().typeId)) {
    Hive.registerAdapter(HabitAdapter());
  }
  
  // 3. Membuka box penyimpanan database lokal Hive
  await Hive.openBox<Habit>('habits');

  // 4. Inisialisasi Layanan Notifikasi Lokal
  await NotificationService().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitProvider()..loadHabits(),
      child: MaterialApp(
        title: 'StudyFlow Habit Tracker',
        debugShowCheckedModeBanner: false,
        
        // --- PHASE 7: POLISH UI GLOBAL THEME ---
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            primary: Colors.indigo,
            secondary: Colors.green,
            surface: Colors.grey[50]!, // Background lembut abu-abu terang
          ),
          
          // Desain Card Global yang modern dan membulat
          cardTheme: CardThemeData(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          // Desain AppBar Clean tanpa garis pemisah kaku
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}