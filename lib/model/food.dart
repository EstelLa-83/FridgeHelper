import 'dart:ffi';

class Food {
  Long? foodId;
  String name;
  DateTime date;
  String quantity;
  String isFrozen;
  String classification;

  Food(
      {required this.name,
      required this.date,
      required this.quantity,
      required this.isFrozen,
      required this.classification});
  // Food({required this.name, required this.quantity, required this.date});
}