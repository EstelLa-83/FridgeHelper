import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationSettings {
  final bool enabled;
  final int daysBefore;
  final int hour;

  NotificationSettings({
    required this.enabled,
    required this.daysBefore,
    required this.hour,
  });
}

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(settings);
}

Future<NotificationSettings> loadNotificationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  return NotificationSettings(
    enabled: prefs.getBool('notificationEnabled') ?? true,
    daysBefore: prefs.getInt('daysBefore') ?? 1,
    hour: prefs.getInt('alarmHour') ?? 13,
  );
}

Future<void> saveNotificationSettings(NotificationSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('notificationEnabled', settings.enabled);
  await prefs.setInt('daysBefore', settings.daysBefore);
  await prefs.setInt('alarmHour', settings.hour);
}
