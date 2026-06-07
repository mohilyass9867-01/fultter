import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                value: false,
                onChanged: (value) {
                  // Logika tema masa depan
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
