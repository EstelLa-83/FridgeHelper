import 'package:flutter/material.dart';
import 'package:fridge/controller/foodImages.dart';

class FridgeFoodCard extends StatelessWidget {
  const FridgeFoodCard({
    super.key,
    required this.name,
    required this.foodImage,
    required this.count,
    required this.expiryDate,
    required this.onDelete,
    required this.onEdit,
  });

  final String name;
  final int foodImage;
  final int count;
  final DateTime expiryDate;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  String getDdayLabel(DateTime expiryDate) {
    try {
      DateTime today = DateTime.now();
      // 날짜 차이 계산 (시간 차이 무시, 날짜만 비교)
      Duration diff = expiryDate.difference(
        DateTime(today.year, today.month, today.day),
      );

      int dDay = diff.inDays;

      if (dDay > 0) {
        return "D-$dDay";
      } else if (dDay == 0) {
        return "D-Day";
      } else {
        return "D+${-dDay}";
      }
    } catch (e) {
      return "Dday Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xffFDFCFF),
        border: Border.all(
          color: Color.fromARGB(255, 243, 243, 243), 
          width: 1.0,        
        ),
        borderRadius: BorderRadius.circular(8.0), 
      ),
      child: Row(
        children: [
          SizedBox(width: 20),
          // 아이콘
          ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: Image.asset(
              foodImages[foodImage],
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.food_bank),
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10,),
          // 텍스트
          Expanded(
            flex: 10,
            child: Container(
              width: 210,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 식품명
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 갯수
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      // 유통기한
                      Text(
                        // 디데이로 표시
                        getDdayLabel(expiryDate),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 수정 버튼
          IconButton(
            icon: const Icon(Icons.create_outlined),
            onPressed: onEdit,
          ),
          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
