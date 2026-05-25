import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');

  List<Habit> get habits => _habits;

  // Memuat data dari database Hive lokal
  void loadHabits() {
    _habits = _habitBox.values.toList();
    notifyListeners();
  }

  // Fungsi Tambah Habit Baru
  void addHabit(String title) {
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
      streakCount: 0,
    );
    
    _habitBox.add(newHabit);
    _habits.add(newHabit);
    notifyListeners();
  }

  // Perbaikan Aman: Melakukan manipulasi langsung tanpa memanggil habit.toggleCompleted()
  void toggleHabitCompletion(int index) {
    if (index >= 0 && index < _habits.length) {
      final habit = _habits[index];
      
      // Balikkan status selesai
      habit.isCompleted = !habit.isCompleted;

      // Logika perhitungan streak harian
      if (habit.isCompleted) {
        habit.streakCount++;
      } else {
        habit.streakCount = (habit.streakCount > 0) ? habit.streakCount - 1 : 0;
      }
      
      // Simpan perubahan ke index box Hive yang tepat
      _habitBox.putAt(index, habit);
      notifyListeners();
    }
  }

  // Perbaikan Aman: Menghapus data menggunakan index box Hive secara langsung
  void deleteHabit(int index) {
    if (index >= 0 && index < _habits.length) {
      _habitBox.deleteAt(index); // Menghapus langsung dari memori disk via Box Index
      _habits.removeAt(index);   // Menghapus dari list memori runtime aplikasi
      notifyListeners();
    }
  }
}