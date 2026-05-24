import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker Kamu'),
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      ),

      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final habits = habitProvider.habits;

          if (habits.isEmpty) {
            return const Center(
              child: Text("Belum ada habit, tambah sekarang!"),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return CheckboxListTile(
                title: Text(habit.title),
                subtitle: Text("Streak: ${habit.streakCount} hari"),
                value: habit.isCompleted,
                onChanged: (bool? newValue) {
                  habitProvider.toggleHabit(index);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => habitProvider.deleteHabit(index),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<HabitProvider>().addHabit(
            "Habit Baru: ${DateTime.now().second}",
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
