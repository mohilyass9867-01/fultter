import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');

  List<Habit> get habits => _habitBox.values.toList();

  // Fungsi untuk menambah habit
  void addHabit(String title) {
    final newHabit = Habit(id: DateTime.now().toString(), title: title);
    _habitBox.add(newHabit);
    notifyListeners();
  }

  // Fungsi untuk hapus
  void deleteHabit(int index) {
    _habitBox.deleteAt(index);
    notifyListeners();
  }

  // Fungsi untuk toggle status habit
  void toggleHabit(int index) {
    final habit = _habitBox.getAt(index);
    if (habit != null) {
      habit.toggleCompleted();
      notifyListeners();
    }
  }
}
