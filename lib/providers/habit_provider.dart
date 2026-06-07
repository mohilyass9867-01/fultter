import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/notification_service.dart'; // Hubungkan dengan layanan notifikasi

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');

  List<Habit> get habits => _habits;

  // Memuat data dari database Hive lokal
  void loadHabits() {
    _habits = _habitBox.values.toList();
    notifyListeners();
  }

  // Fungsi Tambah Habit Baru dengan trigger Notifikasi Instant
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

    // Trigger Notifikasi Berhasil Dibuat
    NotificationService().showInstantNotification(
      id: newHabit.hashCode,
      title: 'Habit Baru Dibuat! 🚀',
      body: 'Rutinitas "$title" siap untuk kamu disiplinkan hari ini!',
    );
  }

  // Melakukan manipulasi langsung status selesai disertai Notifikasi Selamat atas Streak
  void toggleHabitCompletion(int index) {
    if (index >= 0 && index < _habits.length) {
      final habit = _habits[index];

      // Balikkan status selesai
      habit.isCompleted = !habit.isCompleted;

      // Logika perhitungan streak harian
      if (habit.isCompleted) {
        habit.streakCount++;

        // Kirim Notifikasi Selamat jika user berhasil menyelesaikan habit
        NotificationService().showInstantNotification(
          id: habit.hashCode,
          title: 'Kerja Bagus! ✨',
          body:
              'Kamu mempertahankan "${habit.title}" hingga ${habit.streakCount} Hari Streak!',
        );
      } else {
        habit.streakCount = (habit.streakCount > 0) ? habit.streakCount - 1 : 0;
      }

      // Simpan perubahan ke index box Hive yang tepat
      _habitBox.putAt(index, habit);
      notifyListeners();
    }
  }

  // Menghapus data menggunakan index box Hive secara langsung
  void deleteHabit(int index) {
    if (index >= 0 && index < _habits.length) {
      _habitBox.deleteAt(index);
      _habits.removeAt(index);
      notifyListeners();
    }
  }
}
