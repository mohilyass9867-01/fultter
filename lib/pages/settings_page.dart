import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan data state dari HabitProvider secara real-time
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.dark_mode_outlined,
                color: Colors.indigo,
              ),
              title: const Text('Mode Gelap (Dark Mode)'),
              subtitle: const Text('Ubah tema tampilan aplikasi'),
              trailing: Switch(
                // Nilai sakelar sinkron dengan database lokal via HabitProvider
                value: habitProvider.isDarkMode,
                onChanged: (bool value) {
                  // Memicu perubahan tema secara global saat ditekan
                  habitProvider.toggleTheme(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_outlined, color: Colors.indigo),
              title: const Text('Ekspor & Cadangan Data'),
              subtitle: const Text('Simpan data habit dalam format JSON'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Logika backup masa depan
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'StudyFlow Habit Tracker v1.0.0\nProject Pembelajaran Mandiri',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}