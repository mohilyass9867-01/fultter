import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int streakCount;

  Habit({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.streakCount = 0,
  });

  void toggleCompleted() {
    isCompleted = !isCompleted;

    // Logika streak: Jika selesai, streak tambah. Jika batal, streak kurang.
    if (isCompleted) {
      streakCount++;
    } else {
      streakCount = (streakCount > 0) ? streakCount - 1 : 0;
    }
    save();
  }
}
