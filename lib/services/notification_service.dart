import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Explicitly create notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'streak_channel',
      'Streak Reminders',
      description: 'Reminders to keep your workout streak alive',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleStreakReminder({required int hoursDelay}) async {
    // Cancel the old reminder so they don't stack up
    await flutterLocalNotificationsPlugin.cancel(id: 0);

                                        //TODO Change too //Duration(hours: hoursDelay)
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'streak_channel',
        'Streak Reminders',
        channelDescription: 'Reminders to keep your workout streak alive',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Don\'t lose your streak',
        body: 'It\'s been a while since your last workout. Time to slay your enemies',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Fallback if exact alarms are restricted on device
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Don\'t lose your streak',
        body: 'It\'s been a while since your last workout. Time to slay your enemies',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelStreakReminder() async {
    await flutterLocalNotificationsPlugin.cancel(id: 0);
  }
}
