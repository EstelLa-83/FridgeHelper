import 'package:flutter/material.dart';

class FridgeFoodCard extends StatelessWidget {
  const FridgeFoodCard({
    super.key,
    required this.name,
    required this.count,
    required this.expiryDate,
    required this.onDelete,
    required this.onEdit,
  });
  final String name;
  final int count;
  final String expiryDate;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  String getDdayLabel(String expiryDateStr) {
    try {
      DateTime expiryDate = DateTime.parse(expiryDateStr);
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
      height: 70,
      color: const Color(0xffFDFCFF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 아이콘
          Flexible(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(5.0),
              child: const Icon(Icons.food_bank_outlined),
            ),
          ),
          // 텍스트
          Flexible(
            flex: 10,
            child: Container(
              width: 210,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 식품명
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 갯수
                      Text('$count'),
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
          // 삭제 버튼
          Flexible(
            flex: 2,
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
            ),
          ),
          // 수정 버튼
          Flexible(
            flex: 2,
            child: IconButton(
              icon: const Icon(Icons.create_outlined),
              onPressed: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}
