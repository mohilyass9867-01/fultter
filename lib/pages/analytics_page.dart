import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits;

    // Membuat list 7 hari terakhir ke belakang untuk header kolom kalender statistik
    final List<DateTime> pastSevenDays = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grafik Kalender & Streak',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: allHabits.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data habit untuk dianalisis.',
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 14, 9, 9)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD RINGKASAN TOTAL STREAK UTAMA
                  _buildSummaryHeader(context, allHabits),
                  const SizedBox(height: 24),

                  const Text(
                    'Visualisasi Kalender (7 Hari Terakhir)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Warna hijau menandakan target tercapai, warna merah menandakan hari bolong.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LIST IMPLEMENTASI GRAFIK KALENDER PER HABIT
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allHabits.length,
                    itemBuilder: (context, index) {
                      final habit = allHabits[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Baris Nama Habit dan Status Streak Saat Ini
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    habit.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${habit.streak} Hari',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 24),

                              // Baris Grid Kotak Kalender Bulat
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: pastSevenDays.map((date) {
                                  final dateStr = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(date);
                                  final isToday =
                                      DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()) ==
                                      dateStr;

                                  // Cek apakah tanggal ini ada di dalam list history keberhasilan
                                  final bool wasCompleted =
                                      habit.completedDates?.contains(dateStr) ??
                                      false;

                                  return Column(
                                    children: [
                                      // Nama Hari Singkat (Sen, Sel, Rab...)
                                      Text(
                                        DateFormat('E').format(date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isToday
                                              ? Colors.blue
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Kotak Status Hijau (Streak) atau Merah (Bolong)
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: wasCompleted
                                              ? Colors.green.withValues(
                                                  alpha: 0.2,
                                                )
                                              : Colors.red.withValues(
                                                  alpha: 0.1,
                                                ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: wasCompleted
                                                ? Colors.green
                                                : Colors.red.withValues(
                                                    alpha: 0.5,
                                                  ),
                                            width: isToday ? 2.5 : 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: wasCompleted
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                  size: 18,
                                                )
                                              : const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Angka Tanggal Mini
                                      Text(
                                        DateFormat('d').format(date),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, List<Habit> habits) {
    int totalStreak = 0;
    int highestStreak = 0;
    for (var h in habits) {
      totalStreak += h.streak;
      if (h.streak > highestStreak) highestStreak = h.streak;
    }

    // Mengambil skema warna dari tema aktif aplikasi
    final theme = Theme.of(context);

    return Card(
      color: Colors.blueAccent.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.blueAccent, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'Total Akumulasi',
                  style: TextStyle(
                    // Perbaikan: Diganti ke onSurfaceVariant agar adaptif kontras tinggi di kedua mode
                    color: theme.colorScheme.onSurfaceVariant, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalStreak 🔥',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            Column(
              children: [
                Text(
                  'Streak Tertinggi',
                  style: TextStyle(
                    // Perbaikan: Diganti ke onSurfaceVariant agar adaptif kontras tinggi di kedua mode
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$highestStreak 👑',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}