import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fridge/service/notification_service.dart';
import 'package:fridge/model/food.dart';
import 'package:fridge/controller/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchFoodsFromServer(String accessToken) async {
  final response = await http.get(
    Uri.parse('$BASE_URL/foods/group'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to fetch food list. Code: ${response.statusCode}');
  }
}


Future<void> syncAllExpiringNotifications() async {
  final settings = await loadNotificationSettings();
  if (!settings.enabled) {
    await flutterLocalNotificationsPlugin.cancelAll();
    return;
  }

  final accessToken = await storage.read(key: 'accessToken');
  if (accessToken == null) {
    print("AccessToken not found");
    return;
  }

  try {
    final rawFoods = await fetchFoodsFromServer(accessToken);

    final List<Food> foodList = rawFoods.map((f) => Food(
      name: f["name"],
      date: DateTime.parse(f["expiryDate"]),
      count: f["count"],
      isFrozen: f["storageType"],
    )).toList();

    await scheduleGroupedNotifications(foodList);
  } catch (e) {
    print('알림 동기화 실패: $e');
  }
}

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

    print("⏰ 알림 예약됨 - ${tzDate.toLocal()} / ${count}개 품목");


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