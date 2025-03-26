import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/page/page_main.dart';
import 'package:fridge/controller/food_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => FoodNotifier())],
    child: MyApp(),
  ));
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
        '/main': (context) => const MainPage()
      }
    );
  }
}