import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridge/service/noti_scheduler.dart';
import 'package:fridge/service/notification_service.dart';
import 'dart:convert';
import 'package:fridge/model/food.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _FridgePageState();
}

class _FridgePageState extends State<SettingPage> {
  bool _notificationEnabled = true;
  int _daysBefore = 1;
  int _hour = 13;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 저장된 설정 로딩
  }

  Future<void> _loadSettings() async {
    final settings = await loadNotificationSettings();
    setState(() {
      _notificationEnabled = settings.enabled;
      _daysBefore = settings.daysBefore;
      _hour = settings.hour;
    });
  }

  Future<List> loadFoodInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('cached_food_list');

    if (jsonString != null) {
      return jsonDecode(jsonString); // JSON 문자열 → List
    } else {
      return []; // 없으면 빈 리스트 반환
    }
  }

  Future<void> _saveSettings() async {
    final settings = NotificationSettings(
      enabled: _notificationEnabled,
      daysBefore: _daysBefore,
      hour: _hour,
    );
    await saveNotificationSettings(settings);

    // 알림 재스케줄 호출
    final rawList = await loadFoodInfo(); // List<dynamic>
    final foodList = rawList.map((e) => Food.fromJson(e)).toList();
    await scheduleGroupedNotifications(foodList);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !_notificationEnabled;

    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: isDisabled ? Colors.grey : Colors.black87,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('설정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 알림 설정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '알림 설정',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: _notificationEnabled,
                        activeColor: const Color(0xFF395BA9),
                        onChanged: (value) {
                          setState(() => _notificationEnabled = value);
                          _saveSettings(); // 변경 저장
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 알림 시간 설명
                  Text('유통기한 알림 시간 설정', style: labelStyle),
                  const SizedBox(height: 4),
                  Text(
                    '유통기한이 다가올 때 언제 알림을 받을지 설정하세요.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 드롭다운 2개
                  AbsorbPointer(
                    absorbing: isDisabled,
                    child: Opacity(
                      opacity: isDisabled ? 0.4 : 1.0,
                      child: Row(
                        children: [
                          Flexible(
                            child: DropdownButtonFormField<int>(
                              value: _daysBefore,
                              decoration: _dropdownDecoration('며칠 전'),
                              items: List.generate(
                                8,
                                (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text('$i일 전'),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _daysBefore = value ?? 1);
                                _saveSettings();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: DropdownButtonFormField<int>(
                              value: _hour,
                              decoration: _dropdownDecoration('몇 시'),
                              items: List.generate(
                                24,
                                (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text(
                                    i == 0
                                        ? '자정'
                                        : i < 12
                                        ? '오전 $i시'
                                        : i == 12
                                        ? '정오'
                                        : '오후 ${i - 12}시',
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _hour = value ?? 13);
                                _saveSettings();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('테스트 알림 예약 완료 (10초 후 울림)')),
                );
              },
              child: const Text('테스트 알림 보내기'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF1F3F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
