import 'package:flutter/material.dart';
import 'package:fridge/controller/profileImages.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final int profile;
  final bool isMe;

  const MemberCard({
    super.key,
    required this.name,
    required this.profile,
    this.isMe = false,   
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: isMe
            ? Border.all(color: Colors.blueAccent, width: 2.0)
            : Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x32000000),
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              // 프로필 이미지 
              ClipOval(
                child: Image.asset(
                  profileImages[profile],
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? '$name (ME)' : name,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        color: isMe ? Colors.blueAccent : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
         ],
          ),
        ),
      ),
    );
  }
}
