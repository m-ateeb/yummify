class MealModel {
  final String id;
  final String name;
  final int calories;
  final DateTime date;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
  });

  factory MealModel.fromMap(Map<String, dynamic> map, String id) {
    return MealModel(
      id: id,
      name: map['name'],
      calories: map['calories'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }
}
