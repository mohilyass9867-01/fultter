import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Inisialisasi Singleton Instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi awal pengaturan notifikasi platform
  Future<void> initNotification() async {
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
  }

  // Fungsi Instan untuk mengirimkan notifikasi pengingat langsung
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
}
