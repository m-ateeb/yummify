class CookbookEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? authorId;        // nullable
  final DateTime? createdAt;     // nullable
  final DateTime? updatedAt;     // nullable
  final bool isUserRecipe;       // new flag

  CookbookEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.authorId,
    this.createdAt,
    this.updatedAt,
    this.isUserRecipe = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static CookbookEntity fromMap(Map<String, dynamic> map, String id) {
    return CookbookEntity(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      authorId: map['authorId'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isUserRecipe: true, // since it's from Firebase
    );
  }

  static fromEdamam(Map<String, dynamic> recipe) {
    return CookbookEntity(
      id: '', // Firestore will generate the ID
      title: recipe['label'] ?? '',
      description: recipe['source'] ?? '',
      imageUrl: recipe['image'] ?? '',
      authorId: null, // No author for Edamam recipes
      createdAt: null, // No creation date for Edamam recipes
      updatedAt: null, // No update date for Edamam recipes
      isUserRecipe: false, // This is not a user recipe
    );

  }
}
