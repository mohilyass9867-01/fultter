import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final totalHabits = habitProvider.habits.length;
    final completedHabits = habitProvider.habits
        .where((h) => h.isCompleted)
        .length;

    final double completionRate = totalHabits > 0
        ? (completedHabits / totalHabits)
        : 0.0;

    // Mencari streak tertinggi untuk kalkulasi proporsi diagram batang
    int maxStreak = 0;
    for (var habit in habitProvider.habits) {
      if (habit.streakCount > maxStreak) {
        maxStreak = habit.streakCount;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Produktivitas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RINGKASAN PROGRESS UTAMA
            Card(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completion Rate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(completionRate * 100).toStringAsFixed(0)}% Kebiasaan Selesai',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completedHabits dari $totalHabits rutinitas hari ini',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: completionRate,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          '${(completionRate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- OPSI A: DIAGRAM VISUALISASI STREAK BAR CHART ---
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Grafik Konsistensi (Streak)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: totalHabits == 0
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Masukkan habit untuk melihat grafik grafik.',
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalHabits,
                        itemBuilder: (context, index) {
                        final habit = habitProvider.habits[index];
                        // Proporsi diagram batang berdasarkan perbandingan streak
                        final double barWidthFactor = maxStreak > 0
                            ? (habit.streakCount / maxStreak)
                            : 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    habit.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${habit.streakCount} Hari 🔥',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: habit.streakCount > 0
                                          ? Colors.orange[700]
                                          : Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Struktur Batang Kustom Grafik
                              Container(
                                width: double.infinity,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: (barWidthFactor * 100).round() == 0
                                          ? 1
                                          : (barWidthFactor * 100).round(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: habit.streakCount > 0
                                                ? [Colors.orange, Colors.amber]
                                                : [
                                                    Colors.grey[400]!,
                                                    Colors.grey[300]!,
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex:
                                          100 -
                                                  (barWidthFactor * 100)
                                                      .round() <=
                                              0
                                          ? 1
                                          : 100 -
                                                (barWidthFactor * 100).round(),
                                      child: const SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            ),
          ],
      ),
    ));
  }
}
