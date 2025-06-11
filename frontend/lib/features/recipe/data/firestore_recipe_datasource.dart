import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/recipe_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreRecipeDataSourceProvider = Provider<FirestoreRecipeDataSource>((ref) {
  return FirestoreRecipeDataSource();
});
class FirestoreRecipeDataSource {
  final _recipesRef = FirebaseFirestore.instance.collection('recipes');

  /// Create a new recipe document
  // Future<void> createRecipe(RecipeEntity recipe) async {
  //   await _recipesRef.add(recipe.toMap());
  // }


  /// Fetch public recipes or recipes by a specific user
  Future<List<RecipeEntity>> getRecipes({String? userId}) async {
    QuerySnapshot snapshot;

    if (userId != null) {
      snapshot = await _recipesRef
          .where('createdBy', isEqualTo: userId)
          .get();
    } else {
      snapshot = await _recipesRef
          .where('isPublic', isEqualTo: true)
          .get();
    }

    return snapshot.docs
        .map((doc) => RecipeEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Toggle like/unlike
  Future<void> toggleLike(String recipeId, String userId) async {
    final doc = _recipesRef.doc(recipeId);
    final snapshot = await doc.get();
    final data = snapshot.data() as Map<String, dynamic>;

    List<String> likedBy = List<String>.from(data['likedBy'] ?? []);
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }

    await doc.update({'likedBy': likedBy});
  }

  /// Toggle bookmark/unbookmark
  Future<void> toggleBookmark(String recipeId, String userId) async {
    final doc = _recipesRef.doc(recipeId);
    final snapshot = await doc.get();
    final data = snapshot.data() as Map<String, dynamic>;

    List<String> bookmarkedBy = List<String>.from(data['bookmarkedBy'] ?? []);
    if (bookmarkedBy.contains(userId)) {
      bookmarkedBy.remove(userId);
    } else {
      bookmarkedBy.add(userId);
    }

    await doc.update({'bookmarkedBy': bookmarkedBy});
  }

  /// Get one recipe by ID (for detail screen)
  Future<RecipeEntity> getRecipeById(String id) async {
    final doc = await _recipesRef.doc(id).get();
    return RecipeEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateRecipe(RecipeEntity updatedRecipe) async {
    final docRef = FirebaseFirestore.instance.collection('recipes').doc(updatedRecipe.id);
    await docRef.update(updatedRecipe.toMap());
  }
  Future<void> createRecipe(RecipeEntity recipe) async {
    final docRef = FirebaseFirestore.instance.collection('recipes').doc();
    await docRef.set(recipe.toMap());
  }
  Future<void> deleteRecipe(String recipeId) async {
    await _recipesRef.doc(recipeId).delete();
  }
}

