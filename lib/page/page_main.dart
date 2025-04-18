import 'package:fridge/page/page_fridge_collection.dart';
import 'package:fridge/page/page_family.dart';
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
    Page(Icons.home_filled, "fridgeCollection"),
    Page(Icons.group, "family"),
    Page(Icons.person, "setting"),
  ];

  final _buildBody = <Widget>[
    FridgeCollectionPage(), 
    FamilyPage(),
    SettingPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: idx,
        onTap: (x) {
          setState(() {
            idx = x;
          });
        },
        elevation: 20.0,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color(0xff395BA9),
        items:
            pageList
                .map(
                  (Page page) => BottomNavigationBarItem(
                    backgroundColor: Colors.white,
                    icon: Icon(page.iconData),
                    label: page.text,
                  ),
                )
                .toList(),
      ),
      body: _buildBody[idx],
    );
  }
}
