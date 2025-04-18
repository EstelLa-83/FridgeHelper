import 'package:flutter/material.dart';

const List<Widget> menu = <Widget>[
  Text('All'),
  Text('COLD'),
  Text('FROZEN'),
];

class FridgeDivider extends StatefulWidget {
  final void Function(String selectedType) onTypeChanged;

  const FridgeDivider({
    super.key, 
    required this.onTypeChanged
  });

  @override
  State<FridgeDivider> createState() => _FridgeDividerState();
}

class _FridgeDividerState extends State<FridgeDivider> {
  final List<bool> _selectedMenu = <bool>[true, false, false];
  bool vertical = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffFDFCFF),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ToggleButtons(
              direction: vertical ? Axis.vertical : Axis.horizontal,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _selectedMenu.length; i++) {
                    _selectedMenu[i] = i == index;
                  }
                });

                final selectedType = switch (index) {
                  0 => "ALL",
                  1 => "COLD",
                  2 => "FROZEN",
                  _ => "ALL",
                };
                  
                widget.onTypeChanged(selectedType);
              },
              borderColor: Colors.lightBlueAccent,
              selectedBorderColor: Colors.lightBlueAccent,
              selectedColor: Colors.black,
              fillColor: Colors.lightBlueAccent,
              color: Colors.black,
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 100.0,
              ),
              isSelected: _selectedMenu,
              children: menu,
            ),
          ],
        ),
      )
    );
  }
}