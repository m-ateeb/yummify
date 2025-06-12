import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new recipe
  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    try {
      await _db.collection('recipes').add(recipeData);
      print("Recipe added successfully");
    } catch (e) {
      print("Error adding recipe: $e");
    }
  }

  // Get all recipes
  Stream<QuerySnapshot> getRecipes() {
    return _db.collection('recipes').snapshots();
  }

  // Update a recipe
  Future<void> updateRecipe(String recipeId, Map<String, dynamic> updatedData) async {
    try {
      await _db.collection('recipes').doc(recipeId).update(updatedData);
      print("Recipe updated successfully");
    } catch (e) {
      print("Error updating recipe: $e");
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _db.collection('recipes').doc(recipeId).delete();
      print("Recipe deleted successfully");
    } catch (e) {
      print("Error deleting recipe: $e");
    }
  }
}
