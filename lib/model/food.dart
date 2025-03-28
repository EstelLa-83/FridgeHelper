class Food {
  int? foodId;
  String name;
  DateTime date;
  String quantity;
  String isFrozen;
  String classification;

  Food({
    required this.name,
    required this.date,
    required this.quantity,
    required this.isFrozen,
    required this.classification,
  });
  // Food({required this.name, required this.quantity, required this.date});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
      isFrozen: json['isFrozen'],
      classification: json['classification'],
    );
  }
}
