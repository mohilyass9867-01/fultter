import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/notification_service.dart'; // Menghubungkan kembali jembatan layanan notifikasi

class HabitProvider with ChangeNotifier {
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');
  final Box _settingsBox = Hive.box('settings');
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  // State baru untuk mengontrol sistem Mode Gelap
  bool _isDarkMode = false;

  HabitProvider() {
    checkAndResetNewDay();
    loadThemeSettings(); // Memuat pengaturan tema saat provider pertama kali dibuat
  }

  void loadHabits() {
    checkAndResetNewDay();
    loadThemeSettings(); // Memuat pengaturan tema saat fungsi load dipanggil kembali
  }

  // Getter untuk mengambil daftar habit dengan filter pencarian & kategori
  List<Habit> get habits {
    final allHabits = _habitBox.values.toList();
    return allHabits.where((habit) {
      final matchesSearch = habit.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'Semua' || habit.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Getter baru untuk menyuplai data mode tema aktif ke MaterialApp di main.dart
  bool get isDarkMode => _isDarkMode;

  // ===========================================================================
  // MODULE BARU: FITUR MANAJEMEN TEMA SISTEM (DARK MODE)
  // ===========================================================================

  // Membaca konfigurasi tema pengguna dari local storage Box settings
  void loadThemeSettings() {
    _isDarkMode = _settingsBox.get('isDarkMode', defaultValue: false) as bool;
    notifyListeners();
  }

  // Mengubah status visual tema dan langsung menyimpannya secara permanen ke Hive
  void toggleTheme(bool value) {
    _isDarkMode = value;
    _settingsBox.put('isDarkMode', value);
    notifyListeners(); // Memicu Consumer di main.dart untuk rebuild warna dasar aplikasi
  }

  // ===========================================================================
  // LOGIKA UTAMA OPERASI CRUD & RIWAYAT HABIT (KODE ASLI ANDA)
  // ===========================================================================

  // --- FUNGSI SELEKSI TEMPATAN (GETTER STREAK MINGGUAN) ---
  int getWeeklyStreak(String habitId) {
    return _settingsBox.get('weekly_streak_$habitId', defaultValue: 0) as int;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Menambah Habit Baru
  void addHabit(String name, [String category = 'Umum']) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isCompleted: false,
      streak: 0,
      lastUpdated: todayStr,
      category: category.isEmpty ? 'Umum' : category,
      completedDates: [],
    );
    _habitBox.put(newHabit.id, newHabit);
    notifyListeners();

    // 🔔 INTEGRASI NOTIFIKASI: Mengapresiasi penambahan target rutinitas baru secara instan
    NotificationService().showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Habit Baru Ditambahkan! 🚀',
      body:
          'Mantap! Langkah awal dimulai, mari konsisten melakukan "$name" mulai hari ini!',
    );
  }

  // Mengubah Status Kelayakan Dan Mengisi Kalender Riwayat
  void toggleHabitCompletion(String id) {
    final habit = _habitBox.get(id);
    if (habit != null) {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      habit.completedDates ??= [];

      if (!habit.isCompleted) {
        habit.isCompleted = true;
        habit.streak += 1;
        habit.lastUpdated = todayStr;
        if (!habit.completedDates!.contains(todayStr)) {
          habit.completedDates!.add(todayStr);
        }

        // 🔔 INTEGRASI NOTIFIKASI: Rayakan kesuksesan mencentang habit dan merawat angka streak harian
        NotificationService().showInstantNotification(
          id: id
              .hashCode, // Mengonversi String ID unik dari Hive menjadi format Integer agar aman dibaca sistem alarm HP
          title: 'Luar Biasa! 🔥 Streak Bertambah!',
          body:
              'Kamu menyelesaikan "${habit.name}"! Berhasil mempertahankan streak selama ${habit.streak} hari.',
        );
      } else {
        habit.isCompleted = false;
        if (habit.streak > 0) habit.streak -= 1;
        habit.completedDates!.remove(todayStr);
      }

      habit.save();
      _settingsBox.put('last_open_date', todayStr);
      notifyListeners();
    }
  }

  void deleteHabit(String id) {
    _habitBox.delete(id);
    // Bersihkan juga cache streak mingguan agar tidak menumpuk di memori lokal
    _settingsBox.delete('weekly_streak_$id');
    notifyListeners();
  }

  // Logika Auto-Reset Harian & Validasi Streak Mingguan Otomatis
  void checkAndResetNewDay() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastOpenDate =
        _settingsBox.get('last_open_date', defaultValue: todayStr) as String;

    if (lastOpenDate != todayStr) {
      DateTime lastDate = DateTime.parse(lastOpenDate);
      DateTime today = DateTime.parse(todayStr);
      int differenceInDays = today.difference(lastDate).inDays;

      // 1. EVALUASI STREAK MINGGUAN (Dihitung berdasarkan pergantian kalender minggu ISO)
      DateTime lastMonday = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      ).subtract(Duration(days: lastDate.weekday - 1));
      DateTime todayMonday = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: today.weekday - 1));

      // Jika hari Senin di minggu ini sudah lebih maju daripada minggu saat terakhir aplikasi dibuka
      if (todayMonday.isAfter(lastMonday)) {
        for (var habit in _habitBox.values) {
          bool isWeeklyPerfect = true;
          habit.completedDates ??= [];

          // Memeriksa record absen 7 hari penuh pada minggu lalu (Senin s.d Minggu)
          for (int i = 0; i < 7; i++) {
            DateTime checkDay = lastMonday.add(Duration(days: i));
            String checkDayStr = DateFormat('yyyy-MM-dd').format(checkDay);

            if (!habit.completedDates!.contains(checkDayStr)) {
              isWeeklyPerfect = false; // Ketemu satu hari bolong!
              break;
            }
          }

          int currentWeeklyStreak =
              _settingsBox.get('weekly_streak_${habit.id}', defaultValue: 0)
                  as int;

          if (isWeeklyPerfect) {
            _settingsBox.put(
              'weekly_streak_${habit.id}',
              currentWeeklyStreak + 1,
            );
          } else {
            _settingsBox.put(
              'weekly_streak_${habit.id}',
              0,
            ); // Ada hari bolong, streak mingguan hangus ke 0
          }
        }
      }

      // 2. LOGIKA RESET HARIAN BIASA (Sistem Harian Kamu Sebelumnya)
      for (var habit in _habitBox.values) {
        if (differenceInDays > 1 || !habit.isCompleted) {
          habit.streak = 0;
        }
        habit.isCompleted = false;
        habit.save();
      }

      _settingsBox.put('last_open_date', todayStr);
      notifyListeners();
    }
  }
}
