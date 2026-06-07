import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name; // Properti utama pelacakan filter

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int streak;

  @HiveField(4)
  String lastUpdated;

  @HiveField(5)
  String category; // Pelindung filter halaman utama

  @HiveField(6)
  List<String>? completedDates; // Dibuat nullable (?) untuk toleransi migrasi data lama

  Habit({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.streak = 0,
    required this.lastUpdated,
    this.category = 'Umum',
    this.completedDates,
  });

  // JALUR KOMPATIBILITAS: Menjamin halaman UI lama yang memanggil .title atau .completed tidak eror
  String get title => name;
  set title(String value) => name = value;

  bool get completed => isCompleted;
  set completed(bool value) => isCompleted = value;
}