import '../../features/cookbook/domain/cookbook_entity.dart';

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert RecipeModel to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create RecipeModel from Firestore map
  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      authorId: map['authorId'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to domain entity
  CookbookEntity toEntity() {
    return CookbookEntity(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      authorId: authorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert from domain entity
  // factory RecipeModel.fromEntity(CookbookEntity entity) {
  //   return RecipeModel(
  //     id: entity.id,
  //     title: entity.title,
  //     description: entity.description,
  //     imageUrl: entity.imageUrl,
  //     authorId: entity.authorId,
  //     createdAt: entity.createdAt,
  //     updatedAt: entity.updatedAt,
  //   );
  // }
}
