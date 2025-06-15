// lib/features/ai_recipe_builder/domain/recipe_entity.dart
import 'dart:convert';

class Ingredient {
  final double qty;
  final String unit;
  final String name;
  final String? note; // Nullable note

  Ingredient({
    required this.qty,
    required this.unit,
    required this.name,
    this.note,
  });

  factory Ingredient.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Ingredient(qty: 0.0, unit: '', name: '');
    }
    return Ingredient(
      qty: (map['qty'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      note: map['note']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qty': qty,
      'unit': unit,
      'name': name,
      if (note != null) 'note': note,
    };
  }
}

class DescriptionBlock {
  final String heading1;
  final String body;
  final String image; // URL to an image

  DescriptionBlock({
    required this.heading1,
    required this.body,
    required this.image,
  });

  factory DescriptionBlock.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return DescriptionBlock(heading1: '', body: '', image: '');
    }
    return DescriptionBlock(
      heading1: map['heading1']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
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

  factory InstructionStep.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return InstructionStep(description: '');
    }
    return InstructionStep(description: map['description']?.toString() ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
    };
  }
}

class Nutrition {
  final double calories;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double proteinG;

  Nutrition({
    required this.calories,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.proteinG,
  });

  factory Nutrition.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Nutrition(calories: 0.0, carbsG: 0.0, fatG: 0.0, fiberG: 0.0, proteinG: 0.0);
    }
    return Nutrition(
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      carbsG: (map['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (map['fat_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (map['fiber_g'] as num?)?.toDouble() ?? 0.0,
      proteinG: (map['protein_g'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'protein_g': proteinG,
    };
  }
}

class RecipeEntity {
  final String id;
  final String name;
  final String img;
  final String createdBy; // user ID or 'yummify' or admin ID
  final String role; // 'user', 'admin', 'yummify', etc.
  final String visibility;
  final int totaltime;
  final List<String> tags;
  final String writer;
  final String cuisine;
  final String status;
  final String servingDescription;
  final String servingSize;
  final List<String> searchIndex;
  final List<Ingredient> ingredients;
  final List<DescriptionBlock> descriptionBlocks;
  final List<InstructionStep> instructionSet;
  final Nutrition nutrition;
  final List<Map<String, dynamic>> apiCalls;
  final double review; // This might be a legacy field or can be replaced by averageRating
  final DateTime createdAt;
  final DateTime updatedAt;

  // New fields for rating
  final double averageRating;
  final int ratingCount;
  final double totalRatingSum;

  RecipeEntity({
    required this.id,
    required this.createdBy,
    required this.role,
    required this.visibility,
    required this.name,
    required this.img,
    required this.totaltime,
    required this.writer,
    required this.tags,
    required this.cuisine,
    required this.status,
    required this.servingDescription,
    required this.servingSize,
    required this.searchIndex,
    required this.ingredients,
    required this.descriptionBlocks,
    required this.instructionSet,
    required this.nutrition,
    required this.apiCalls,
    required this.review,
    required this.createdAt,
    required this.updatedAt,
    // New fields with default values
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.totalRatingSum = 0.0,
  });

  factory RecipeEntity.fromMap(Map<String, dynamic>? map, String id) {
    List<Map<String, dynamic>> safeListMap(dynamic list) {
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    }

    return RecipeEntity(
      id: id,
      createdBy: map?['createdBy']?.toString() ?? '',
      role: map?['role']?.toString() ?? 'user',
      visibility: map?['visibility']?.toString() ?? 'public',
      name: map?['name']?.toString() ?? 'Untitled Recipe',
      img: map?['img']?.toString() ?? 'https://placehold.co/800x600/eeeeee/333333?text=No+Image',
      totaltime: (map?['totaltime'] as num?)?.toInt() ?? 0,
      writer: map?['writer']?.toString() ?? 'AI',
      cuisine: map?['cuisine']?.toString() ?? 'Unknown',
      status: map?['status']?.toString() ?? 'public',
      servingDescription: map?['serving_description']?.toString() ?? 'N/A',
      servingSize: map?['serving_size']?.toString() ?? '0',
      searchIndex: List<String>.from(safeListMap(map?['searchIndex']).map((e) => e.toString()))
          .where((s) => s.isNotEmpty).toList(),
      tags: List<String>.from(safeListMap(map?['tags']).map((e) => e.toString()))
          .where((s) => s.isNotEmpty).toList(),
      ingredients: safeListMap(map?['ingredients']).map((e) => Ingredient.fromMap(e)).toList(),
      descriptionBlocks: safeListMap(map?['descriptionBlocks']).map((e) => DescriptionBlock.fromMap(e)).toList(),
      instructionSet: safeListMap(map?['instructionSet']).map((e) => InstructionStep.fromMap(e)).toList(),
      nutrition: Nutrition.fromMap(map?['nutrition'] as Map<String, dynamic>?),
      apiCalls: safeListMap(map?['apiCalls']),
      review: (map?['review'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(map?['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(map?['updatedAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      // New fields from map, with null safety and defaults
      averageRating: (map?['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (map?['ratingCount'] as num?)?.toInt() ?? 0,
      totalRatingSum: (map?['totalRatingSum'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdBy': createdBy,
      'role': role,
      'visibility': visibility,
      'name': name,
      'img': img,
      'tags': tags,
      'writer': writer,
      'totaltime': totaltime,
      'cuisine': cuisine,
      'status': status,
      'serving_description': servingDescription,
      'serving_size': servingSize,
      'searchIndex': searchIndex,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'descriptionBlocks': descriptionBlocks.map((e) => e.toMap()).toList(),
      'instructionSet': instructionSet.map((e) => e.toMap()).toList(),
      'nutrition': nutrition.toMap(),
      'apiCalls': apiCalls,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'totalRatingSum': totalRatingSum,
    };
  }

  RecipeEntity copyWith({
    String? id,
    String? name,
    String? img,
    String? createdBy,
    String? role,
    String? visibility,
    int? totaltime,
    List<String>? tags,
    String? writer,
    String? cuisine,
    String? status,
    String? servingDescription,
    String? servingSize,
    List<String>? searchIndex,
    List<Ingredient>? ingredients,
    List<DescriptionBlock>? descriptionBlocks,
    List<InstructionStep>? instructionSet,
    Nutrition? nutrition,
    List<Map<String, dynamic>>? apiCalls,
    double? review,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageRating,
    int? ratingCount,
    double? totalRatingSum,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      img: img ?? this.img,
      createdBy: createdBy ?? this.createdBy,
      role: role ?? this.role,
      visibility: visibility ?? this.visibility,
      totaltime: totaltime ?? this.totaltime,
      tags: tags ?? this.tags,
      writer: writer ?? this.writer,
      cuisine: cuisine ?? this.cuisine,
      status: status ?? this.status,
      servingDescription: servingDescription ?? this.servingDescription,
      servingSize: servingSize ?? this.servingSize,
      searchIndex: searchIndex ?? this.searchIndex,
      ingredients: ingredients ?? this.ingredients,
      descriptionBlocks: descriptionBlocks ?? this.descriptionBlocks,
      instructionSet: instructionSet ?? this.instructionSet,
      nutrition: nutrition ?? this.nutrition,
      apiCalls: apiCalls ?? this.apiCalls,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      totalRatingSum: totalRatingSum ?? this.totalRatingSum,
    );
  }
}
