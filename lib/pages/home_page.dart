import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;

    return Scaffold(
      appBar: AppBar(title: const Text('StudyFlow Habits')),
      body: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada habit hari ini.\nMulai produktif sekarang!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: habits.length,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemBuilder: (context, index) {
                final habit = habits[index];

                // --- PHASE 7: MODERNIZE LIST ITEM TO CARD ---
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onLongPress: () {
                      _showDeleteDialog(context, habitProvider, habit, index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: habit.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: habit.isCompleted
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: habit.streakCount > 0
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.streakCount} Hari Streak',
                              style: TextStyle(
                                fontSize: 13,
                                color: habit.streakCount > 0
                                    ? Colors.orange[700]
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        value: habit.isCompleted,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          habitProvider.toggleHabitCompletion(index);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddHabitBottomSheet(context, habitProvider);
        },
        label: const Text('Tambah Habit'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  // Dialog Konfirmasi Hapus Clean Look
  void _showDeleteDialog(
    BuildContext context,
    HabitProvider provider,
    Habit habit,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Habit'),
        content: Text('Apakah kamu yakin ingin menghapus "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () {
              provider.deleteHabit(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${habit.title} berhasil dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Bottom Sheet Tambah Habit Modern (Bebas dari Deprecated warning withOpacity)
  void _showAddHabitBottomSheet(BuildContext context, HabitProvider provider) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Habit Baru ✨',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Misal: Belajar Flutter 1 Jam',
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.edit_calendar),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    provider.addHabit(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Simpan Rutinitas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
