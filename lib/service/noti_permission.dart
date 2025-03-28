import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> requestExactAlarmPermissionIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  final alreadyRequested = prefs.getBool('exactAlarmPermissionRequested') ?? false;

  if (!alreadyRequested && Platform.isAndroid) {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();

    await prefs.setBool('exactAlarmPermissionRequested', true);
  }
}

Future<void> requestNotificationPermissionIfNeeded() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    final result = await Permission.notification.request();
    print('🔔 일반 알림 권한 요청 결과: $result');
  }
}