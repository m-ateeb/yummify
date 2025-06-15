import '../../features/cookbook/domain/cookbook_entity.dart';

class Ingredient {
  final double qty;
  final String name;

  Ingredient({required this.qty, required this.name});

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      qty: (map['qty'] ?? 0).toDouble(),
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qty': qty,
      'name': name,
    };
  }
}

class DescriptionBlock {
  final String heading1;
  final String body;
  final String image;

  DescriptionBlock({
    required this.heading1,
    required this.body,
    required this.image,
  });

  factory DescriptionBlock.fromMap(Map<String, dynamic> map) {
    return DescriptionBlock(
      heading1: map['heading1'] ?? '',
      body: map['body'] ?? '',
      image: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heading1': heading1,
      'body': body,
      'image': image,
    };
  }
}

class InstructionStep {
  final String description;

  InstructionStep({required this.description});

  factory InstructionStep.fromMap(Map<String, dynamic> map) {
    return InstructionStep(description: map['description'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
    };
  }
}

class Micronutrients {
  final List<String> minerals;
  final List<String> vitamins;

  Micronutrients({required this.minerals, required this.vitamins});

  factory Micronutrients.fromMap(Map<String, dynamic> map) {
    return Micronutrients(
      minerals: List<String>.from(map['minerals'] ?? []),
      vitamins: List<String>.from(map['vitamins'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minerals': minerals,
      'vitamins': vitamins,
    };
  }
}

class RecipeModel {
  final String id;
  final String img;
  final String writer; // This is the user ID (reference)
  final String status; // 'public' or 'private'
  final List<Ingredient> ingredients;
  final List<DescriptionBlock> descriptionBlocks;
  final List<InstructionStep> instructionSet;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final Micronutrients micronutrients;
  final List<Map<String, dynamic>> apiCalls;
  final double review;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    required this.id,
    required this.img,
    required this.writer,
    required this.status,
    required this.ingredients,
    required this.descriptionBlocks,
    required this.instructionSet,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.micronutrients,
    required this.apiCalls,
    required this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      img: map['img'] ?? '',
      writer: map['writer'] ?? '',
      status: map['status'] ?? 'public',
      ingredients: List<Map<String, dynamic>>.from(map['ingredients'] ?? [])
          .map((e) => Ingredient.fromMap(e))
          .toList(),
      descriptionBlocks: List<Map<String, dynamic>>.from(map['descriptionBlocks'] ?? [])
          .map((e) => DescriptionBlock.fromMap(e))
          .toList(),
      instructionSet: List<Map<String, dynamic>>.from(map['instructionSet'] ?? [])
          .map((e) => InstructionStep.fromMap(e))
          .toList(),
      calories: (map['calories'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
      micronutrients: Micronutrients.fromMap(map['micronutrients'] ?? {}),
      apiCalls: List<Map<String, dynamic>>.from(map['apiCalls'] ?? []),
      review: (map['review'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'img': img,
      'writer': writer,
      'status': status,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'descriptionBlocks': descriptionBlocks.map((e) => e.toMap()).toList(),
      'instructionSet': instructionSet.map((e) => e.toMap()).toList(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'micronutrients': micronutrients.toMap(),
      'apiCalls': apiCalls,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
