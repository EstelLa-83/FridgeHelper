import 'package:fridge/page/page_fridge.dart';
import 'package:fridge/page/page_setting.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class Page {
  const Page(this.iconData, this.text);
  final IconData iconData;
  final String text;
}

class _MainPageState extends State<MainPage> {
  int idx = 0;

  final pageList = const <Page>[
    Page(Icons.home_filled, "fridgy"),
    Page(Icons.person, "setting"),
  ];

  final _buildBody = <Widget>[
    FridgePage(),
    SettingPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}