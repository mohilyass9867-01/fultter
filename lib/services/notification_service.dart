import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Inisialisasi Singleton Instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi awal pengaturan notifikasi platform
  Future<void> initNotification() async {
    // 1. Inisialisasi database Zona Waktu untuk sistem penjadwalan harian
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Menggunakan zona waktu Indonesia (WIB)

    // Pengaturan icon untuk notifikasi Android (menggunakan icon bawaan launcher default)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Meminta izin/permission eksplisit untuk perangkat Android 13+ / API 33+
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _localNotificationsPlugin.initialize(initializationSettings);

    // 2. Jalankan penjadwalan otomatis notifikasi motivasi pagi setiap kali aplikasi dibuka
    await scheduleMorningNotification();
  }

  // Fungsi Instan untuk mengirimkan notifikasi pengingat langsung (saat tambah/selesai habit)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'studyflow_habit_channel', // ID Channel unik
          'Habit Reminders', // Nama Channel yang terlihat di pengaturan HP
          channelDescription: 'Notifikasi pengingat untuk rutinitas harian',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // ====== FITUR BARU: Penjadwalan Notifikasi Motivasi Pagi Hari ======
  Future<void> scheduleMorningNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'studyflow_morning_channel', // ID Channel khusus pesan pagi
      'Morning Motivation', // Nama Channel khusus di pengaturan HP
      channelDescription: 'Notifikasi harian penyemangat pagi untuk memulai habit',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Menembakkan jadwal notifikasi harian berulang
    await _localNotificationsPlugin.zonedSchedule(
      888, // ID unik statis khusus untuk alarm motivasi pagi agar tidak tumpang tindih
      'Selamat Pagi! Semangat Baru! ☀️',
      'Jangan biarkan streak-mu putus hari ini. Yuk, buka StudyFlow dan mulai habit pertamamu!',
      _nextInstanceOfMorningTime(7, 0), // Mengatur waktu eksekusi otomatis jam 07:00 pagi
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Tetap muncul meski HP dalam mode istirahat/idle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Kunci utama agar notifikasi berulang SETIAP HARI pada jam yang sama
    );
  }

  // Helper fungsi untuk mencari kapan waktu jam 7 pagi berikutnya akan datang
  tz.TZDateTime _nextInstanceOfMorningTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Jika jam 7 pagi hari ini sudah lewat, maka jadwal otomatis dialihkan ke jam 7 pagi keesokan harinya
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}