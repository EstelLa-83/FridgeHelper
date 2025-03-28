import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fridge/service/notification_service.dart';
import 'package:fridge/model/food.dart';

/// 유통기한 임박 알림을 시각별로 묶어서 한 번만 예약하는 함수
Future<void> scheduleGroupedNotifications(List<Food> foodList) async {
  final settings = await loadNotificationSettings();
  if (!settings.enabled) return;

  // 기존 알림 모두 취소 (중복 방지)
  await flutterLocalNotificationsPlugin.cancelAll();

  // 현재 시각 기준 필터링
  final now = DateTime.now();

  // 시각별로 그룹핑
  final Map<DateTime, List<Food>> grouped = {};

  for (final food in foodList) {
    // 이미 유통기한 지난 상품은 무시
    if (food.date.isBefore(now)) continue;

    final alarmTime = DateTime(
      food.date.year,
      food.date.month,
      food.date.day - settings.daysBefore,
      settings.hour,
    );

    grouped.putIfAbsent(alarmTime, () => []).add(food);
  }

  for (final entry in grouped.entries) {
    final tzDate = tz.TZDateTime.from(entry.key, tz.local);
    final count = entry.value.length;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      entry.key.hashCode, // 고유 ID
      '🧊 유통기한 임박!',
      '$count개의 유통기한 임박 품목이 있어요!',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fridge_channel',
          'Fridge Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

/// 테스트용 알림 예약: 현재 시각 기준 10초 뒤 알림 울리기
Future<void> showTestNotification() async {
  final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

  print('✅ 알림 예약 시각: $scheduled');

  await flutterLocalNotificationsPlugin.zonedSchedule(
    999999,
    '🔔 테스트 알림!',
    '알림이 정상적으로 작동 중입니다.',
    scheduled,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'fridge_channel',
        'Fridge Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
  );

  print('✅ zonedSchedule 호출 완료');
}