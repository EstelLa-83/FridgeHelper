import 'package:flutter/material.dart';
import 'package:fridge/model/fridge.dart';

class FridgeCollectionCard extends StatelessWidget {
  const FridgeCollectionCard({
    super.key, 
    required this.routefunc, 
    required this.fridge,
    required this.onEdit,
    required this.onDelete,
  });

  final Function() routefunc;
  final Fridge fridge;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: routefunc,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: 150.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x230E151B),
              offset: Offset(0.0, 2.0),
            )
          ],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              // 수정/삭제 아이콘 Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                    padding: EdgeInsets.zero, // ← 패딩 제거
                    constraints: const BoxConstraints(), // ← 크기 최소화
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero, // ← 패딩 제거
                    constraints: const BoxConstraints(), // ← 크기 최소화
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 2.0),
              const Spacer(),

              // 냉장고 이름
              Center(
                child: Text(
                  fridge.fridgeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 10.0),
              const Spacer(),
            ],          
          ),
        ),
      ),
    );
  }
}