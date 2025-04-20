import 'package:flutter/material.dart';

class FamilyAppBar extends StatelessWidget {
  final String familyName;
  final VoidCallback onRename;
  final VoidCallback onLeave;

  const FamilyAppBar({
    super.key,
    required this.familyName,
    required this.onRename,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // 원하는 높이
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
        child: Stack(
          children: [
            Center(
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
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: onRename,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 5,
              child: TextButton(
                onPressed: onLeave,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 0),
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Leave',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}