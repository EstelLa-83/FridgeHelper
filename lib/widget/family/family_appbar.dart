import 'package:flutter/material.dart';

class FamilyAppBar extends StatelessWidget {
  final String familyName;
  final VoidCallback onRename;

  const FamilyAppBar({
    super.key,
    required this.familyName,
    required this.onRename,
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
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                familyName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: onRename,
              ),
            ],
          ),
        ),
      ),
    );
  }
}