import 'package:flutter/material.dart';
class FridgeAppBar extends StatelessWidget {
  final String fridgeName;
  final VoidCallback onAddPressed;

  const FridgeAppBar({
    super.key,
    required this.fridgeName,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // 원하는 높이
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // 뒤로가기 버튼
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  fridgeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: onAddPressed,
            ),
          ],
        ),
      ),
    );
  }
}