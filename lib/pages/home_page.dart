import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Semua',
    'Umum',
    'Belajar',
    'Kesehatan',
    'Rutinitas',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final theme = Theme.of(context);

    // EVALUASI STATISTIK HARIAN
    final allHabits = habitProvider.habits;
    final completedCount = allHabits.where((h) => h.isCompleted).length;
    final double progressPercent = allHabits.isEmpty
        ? 0.0
        : completedCount / allHabits.length;

    // Menghitung Rekor Streak Harian dan Mingguan Tertinggi
    int maxDailyStreak = 0;
    int maxWeeklyStreak = 0;

    for (var habit in allHabits) {
      if (habit.streak > maxDailyStreak) {
        maxDailyStreak = habit.streak;
      }
      final wStreak = habitProvider.getWeeklyStreak(habit.id);
      if (wStreak > maxWeeklyStreak) {
        maxWeeklyStreak = wStreak;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('StudyFlow Habit Tracker')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================================================================
          // KOTAK CARD UTAMA (WARNA SUDAH DIBUAT ADAPTIF LIGHT/DARK MODE)
          // ===================================================================
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            margin: const EdgeInsets.all(16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progres Hari Ini',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              allHabits.isEmpty
                                  ? 'Belum ada data rutinitas hari ini.'
                                  : '$completedCount dari ${allHabits.length} target selesai hari ini',
                              style: theme
                                  .textTheme
                                  .bodyMedium, // Mengikuti warna teks tema aktif
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 55,
                        height: 55,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progressPercent,
                              strokeWidth: 6,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                            ),
                            Text(
                              '${(progressPercent * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 16),

                  // INFO AKUMULASI STREAK GLOBAL TERATAS
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Streak Harian',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '$maxDailyStreak Hari',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          color: theme.colorScheme.outlineVariant,
                          thickness: 1,
                          indent: 2,
                          endIndent: 2,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👑', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Streak Mingguan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '$maxWeeklyStreak Minggu',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: maxWeeklyStreak > 0
                                          ? const Color.fromARGB(
                                              255,
                                              46,
                                              38,
                                              19,
                                            )
                                          : null, // Kuning amber yang aman di dark mode
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. KOLOM PENCARIAN (SEARCH BAR)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => habitProvider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari nama rutinitas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          habitProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. FILTER KATEGORI HORIZONTAL (CHOICE CHIPS)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = habitProvider.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) =>
                        habitProvider.setSelectedCategory(category),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // 4. DAFTAR INDIVIDUAL HABIT (SUDAH ADAPTIF GELAP/TERANG)
          Expanded(
            child: allHabits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 64,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada aktivitas yang ditemukan',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: allHabits.length,
                    itemBuilder: (context, index) {
                      final habit = allHabits[index];
                      final int weeklyStreak = habitProvider.getWeeklyStreak(
                        habit.id,
                      );

                      return Card(
                        elevation: habit.isCompleted ? 1 : 2,
                        color: habit.isCompleted
                            ? Colors.green.withValues(
                                alpha: 0.15,
                              ) // Sedikit lebih tebal agar kontras di dark mode
                            : theme
                                  .cardColor, // Mengikuti warna latar card tema aktif
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              habit.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: habit.isCompleted
                                  ? Colors.green
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 28,
                            ),
                            onPressed: () =>
                                habitProvider.toggleHabitCompletion(habit.id),
                          ),
                          title: Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: habit.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: habit.isCompleted
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    habit.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '${habit.streak} Hari',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '👑',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '$weeklyStreak Mggu',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: weeklyStreak > 0
                                          ? const Color.fromARGB(
                                              255,
                                              49,
                                              43,
                                              28,
                                            )
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showDeleteConfirmation(
                                    context,
                                    habitProvider,
                                    habit,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitBottomSheet(context, habitProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    HabitProvider provider,
    Habit habit,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rutinitas?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${habit.name}"? Seluruh rekam jejak streak akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddHabitBottomSheet(BuildContext context, HabitProvider provider) {
    final TextEditingController nameController = TextEditingController();
    String selectedCategory = 'Umum';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Kebiasaan Baru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nama Kebiasaan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Kategori:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories.where((cat) => cat != 'Semua').map((
                      cat,
                    ) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            selectedCategory = cat;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final text = nameController.text.trim();
                        if (text.isNotEmpty) {
                          provider.addHabit(text, selectedCategory);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Simpan Aktivitas'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
