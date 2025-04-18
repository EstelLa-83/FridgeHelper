class Food {
  int? foodId;
  String name;
  int count;
  DateTime date;
  String isFrozen;

  Food({
    required this.name,
    required this.count,
    required this.date,
    required this.isFrozen,
  });
  // Food({required this.name, required this.quantity, required this.date});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'],
      count: json['count'],
      date: DateTime.parse(json['date']),
      isFrozen: json['isFrozen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'date': date.toIso8601String(),
      'isFrozen': isFrozen,
    };
  }
}
