import 'package:flutter/material.dart';
import 'package:fridge/page/page_main.dart';
import 'package:fridge/controller/food_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fridge/service/noti_permission.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await requestNotificationPermissionIfNeeded();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridge',
      initialRoute: "/main",
      routes: {
        '/': (context) => const MainPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
