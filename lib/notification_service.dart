import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> _azkar = [
    'سبحان الله',
    'الحمدلله',
    'لا اله الا الله',
    'الله اكبر',
    'لا حول ولا قوة الا بالله',
    'اللهم صلي على النبي',
  ];

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    // Request permissions for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> scheduleInactivityNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'تذكير',
      'هل انتهيت من صلواتك المتاخرة ؟؟',
      tz.TZDateTime.now(tz.local).add(const Duration(days: 2)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'inactivity_channel',
          'Inactivity Reminders',
          channelDescription:
              'Reminds you if you haven\'t opened the app in a while',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelInactivityNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> scheduleAzkarNotifications() async {
    // Cancel existing future azkar notifications to avoid duplicates when reopening app
    await cancelAzkarNotifications();

    final random = Random();
    
    // Schedule for the next 12 hours (72 notifications)
    // Starting 10 minutes from now
    for (int i = 1; i <= 72; i++) {
      final int notificationId = 100 + i; // IDs 101 to 172
      final String zikr = _azkar[random.nextInt(_azkar.length)];
      final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(minutes: 10 * i));

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'ذكر',
          zikr,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'azkar_channel',
              'Azkar Reminders',
              channelDescription: 'Periodic Azkar notifications',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Optional: if we wanted daily, but here we want one-off series
        );
      } catch (e) {
        print('Error scheduling notification $notificationId: $e');
      }
    }
  }

  Future<void> cancelAzkarNotifications() async {
    // Cancel IDs 101 to 172
    for (int i = 1; i <= 72; i++) {
      await flutterLocalNotificationsPlugin.cancel(100 + i);
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}