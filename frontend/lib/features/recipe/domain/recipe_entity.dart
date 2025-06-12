class RecipeEntity {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final bool isPublic;
  final String createdBy;
  final List<String> likedBy;
  final List<String> bookmarkedBy;

  RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.isPublic,
    required this.createdBy,
    required this.likedBy,
    required this.bookmarkedBy,
  });

  factory RecipeEntity.fromMap(Map<String, dynamic> map, String docId) {
    return RecipeEntity(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      isPublic: map['isPublic'] ?? false,
      createdBy: map['createdBy'] ?? '',
      likedBy: List<String>.from(map['likedBy'] ?? []),
      bookmarkedBy: List<String>.from(map['bookmarkedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'isPublic': isPublic,
      'createdBy': createdBy,
      'likedBy': likedBy,
      'bookmarkedBy': bookmarkedBy,
    };
  }
}
