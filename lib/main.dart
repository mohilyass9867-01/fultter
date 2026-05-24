import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'models/habit.dart';
import 'providers/habit_provider.dart'; // 2. Import file HabitProvider kamu
import 'core/theme/app_theme.dart';
import 'core/navigation/app_routes.dart';

void main() async {
  // Pastikan WidgetBinding terinisialisasi jika menggunakan async di main
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive Flutter
  await Hive.initFlutter();

  // 2. Register Adapter
  Hive.registerAdapter(HabitAdapter());

  // 3. Buka "Box"
  await Hive.openBox<Habit>('habits');

  // 4. Jalankan aplikasi dengan Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: const HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,
    );
  }
}
