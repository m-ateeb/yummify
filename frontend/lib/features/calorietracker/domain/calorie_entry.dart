// lib/features/calorietracker/domain/calorie_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CalorieEntry {
  final String id;
  final String mealName;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;
  //final String category; // e.g., 'natural', 'asian', 'chinese'
  final DateTime timestamp;

  CalorieEntry({
    required this.id,
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
   // required this.category,
    required this.timestamp,
  });

  factory CalorieEntry.fromMap(Map<String, dynamic> map, String id) {
    final dynamic timestampValue = map['timestamp'];
    DateTime date;
    if (timestampValue is Timestamp) {
      date = timestampValue.toDate();
    } else if (timestampValue is String) {
      date = DateTime.parse(timestampValue);
    } else {
      date = DateTime.now();
    }

    double parseDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value?.toString() ?? '0') ?? 0.0;
    }

    return CalorieEntry(
      id: id,
      mealName: map['meal'] ?? map['mealName'] ?? '',
      calories: parseDouble(map['calories']),
      protein: parseDouble(map['protein']),
      fat: parseDouble(map['fat']),
      carbs: parseDouble(map['carbs']),
      fiber: parseDouble(map['fiber']),
      //category: map['category'] ?? '',
      timestamp: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'meal': mealName,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'fiber': fiber,
      //'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class Goal {
  final String id;
  final String userId;
  final double targetCalories;
  final DateTime startDate;
  final DateTime endDate;
  final GoalType type;

  Goal({
    required this.id,
    required this.userId,
    required this.targetCalories,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  factory Goal.fromMap(Map<String, dynamic> map, String id) {
    return Goal(
      id: id,
      userId: map['userId'] ?? '',
      targetCalories: (map['targetCalories'] is int)
          ? (map['targetCalories'] as int).toDouble()
          : (map['targetCalories'] as double? ?? 0.0),
      startDate: (map['startDate'] is Timestamp)
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.parse(map['startDate'].toString()),
      endDate: (map['endDate'] is Timestamp)
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.parse(map['endDate'].toString()),
      type: GoalType.values[map['type'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetCalories': targetCalories,
      'startDate': startDate,
      'endDate': endDate,
      'type': type.index,
    };
  }
}

enum GoalType { daily, weekly, monthly }