import 'package:flutter/material.dart';
import 'package:fridge/page/page_login.dart';
import 'package:fridge/page/page_main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fridge/service/noti_permission.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱으로 실행 시 실행 (chrome일 땐 필요 X)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    tz.initializeTimeZones();
    await requestExactAlarmPermissionIfNeeded();
    await requestNotificationPermissionIfNeeded();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridge',
      theme: ThemeData(
        fontFamily: 'NotoSansKR',
      ),
      initialRoute: "/login",
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
