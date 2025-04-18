import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridge/service/noti_scheduler.dart';
import 'package:fridge/service/notification_service.dart';
import 'dart:convert';
import 'package:fridge/model/food.dart';
import 'package:fridge/controller/global.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';

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
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await loadNotificationSettings();
    setState(() {
      _notificationEnabled = settings.enabled;
      _daysBefore = settings.daysBefore;
      _hour = settings.hour;
    });
  }

  Future<void> _saveSettings() async {
    final settings = NotificationSettings(
      enabled: _notificationEnabled,
      daysBefore: _daysBefore,
      hour: _hour,
    );
    await saveNotificationSettings(settings);
    await syncAllExpiringNotifications();
  }

  Future<void> logout(BuildContext context) async {
    final accessToken = await storage.read(key: 'accessToken');

    final response = await http.post(
      Uri.parse('$BASE_URL/auth/logout'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    await storage.deleteAll();

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile-edit');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
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
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text('Reminder Time Settings', style: labelStyle),
                  const SizedBox(height: 4),
                  Text(
                    'Set when you want to receive expiration reminders.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  AbsorbPointer(
                    absorbing: isDisabled,
                    child: Opacity(
                      opacity: isDisabled ? 0.4 : 1.0,
                      child: Row(
                        children: [
                          Flexible(
                            child: DropdownButtonFormField2<int>(
                              value: _daysBefore,
                              isExpanded: true,
                              decoration: _dropdownDecoration('Days Before'),
                              items: List.generate(
                                8,
                                    (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text('$i day${i == 1 ? '' : 's'}'),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _daysBefore = value ?? 1);
                                _saveSettings();
                              },
                              buttonStyleData: const ButtonStyleData(
                                height: 48,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 240,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: DropdownButtonFormField2<int>(
                              value: _hour,
                              isExpanded: true,
                              decoration: _dropdownDecoration('Hour of Day'),
                              items: List.generate(
                                24,
                                    (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text(
                                    i == 0
                                        ? 'Midnight'
                                        : i < 12
                                        ? '$i AM'
                                        : i == 12
                                        ? 'Noon'
                                        : '${i - 12} PM',
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _hour = value ?? 13);
                                _saveSettings();
                              },
                              buttonStyleData: const ButtonStyleData(
                                height: 48,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 240,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                              ),
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
                  const SnackBar(content: Text('Test notification scheduled (in 10 seconds)')),
                );
              },
              child: const Text('Send Test Notification'),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Logout", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                      ],
                    ),
                  );

                  if (shouldLogout != true) return;

                  await logout(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
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
