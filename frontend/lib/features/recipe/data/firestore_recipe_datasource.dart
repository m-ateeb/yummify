import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/recipe_entity.dart';

class FirestoreRecipeDataSource {
  final _recipesRef = FirebaseFirestore.instance.collection('recipes');

  Future<void> createRecipe(RecipeEntity recipe) async {
    final docRef = _recipesRef.doc(); // auto-generate ID
    await docRef.set(recipe.toMap()); // Use recipe.toMap()
  }

  Future<List<RecipeEntity>> getRecipes({String? userId}) async {
    QuerySnapshot snapshot;
    if (userId != null) {
      // Assuming 'writer' field exists in RecipeEntity
      snapshot = await _recipesRef.where('writer', isEqualTo: userId).get();
    } else {
      // Assuming 'status' field exists in RecipeEntity
      snapshot = await _recipesRef.where('status', isEqualTo: 'public').get();
    }

    return snapshot.docs
        .map((doc) => RecipeEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Changed from Future to Stream for real-time updates on a single recipe
  Stream<RecipeEntity> getRecipeStream(String id) {
    return _recipesRef.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        // Handle case where recipe might be deleted or not found
        // You might want to throw an error or return a default/null value
        throw Exception("Recipe with ID $id not found or data is null.");
      }
      return RecipeEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Future<void> updateRecipe(RecipeEntity updatedRecipe) async {
    await _recipesRef.doc(updatedRecipe.id).update(updatedRecipe.toMap()); // Use updatedRecipe.toMap()
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipesRef.doc(recipeId).delete();
  }
  Future<RecipeEntity> getRecipeById(String id) async {
    final doc = await _recipesRef.doc(id).get();
    return RecipeEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
  // --- NEW METHOD FOR RATING ---
  Future<void> updateRecipeRating({
    required String recipeId,
    required String userId,
    required double newRating,
    required double? oldRating, // Pass null if it's a new rating
  }) async {
    final recipeRef = _recipesRef.doc(recipeId);
    final userRatingRef = recipeRef.collection('ratings').doc(userId); // Subcollection for individual user ratings

    // Use a Firestore transaction to ensure atomicity for aggregate updates
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final recipeDoc = await transaction.get(recipeRef);

      if (!recipeDoc.exists || recipeDoc.data() == null) {
        throw Exception("Recipe not found for rating: $recipeId");
      }

      // Re-create RecipeEntity from the transaction's snapshot to get latest values
      final currentRecipe = RecipeEntity.fromMap(recipeDoc.data() as Map<String, dynamic>, recipeDoc.id);

      double updatedTotalRatingSum = currentRecipe.totalRatingSum;
      int updatedRatingCount = currentRecipe.ratingCount;

      if (oldRating == null || oldRating == 0.0) {
        // User is rating for the first time
        updatedTotalRatingSum += newRating;
        updatedRatingCount += 1;
      } else {
        // User is updating their existing rating
        updatedTotalRatingSum = updatedTotalRatingSum - oldRating + newRating;
        // The ratingCount does not change when updating an existing rating
      }

      final newAverageRating = updatedRatingCount > 0
          ? updatedTotalRatingSum / updatedRatingCount
          : 0.0;

      // 1. Update the main recipe document with the new aggregate rating data
      transaction.update(recipeRef, {
        'averageRating': newAverageRating,
        'ratingCount': updatedRatingCount,
        'totalRatingSum': updatedTotalRatingSum,
      });

      // 2. Store or update the user's individual rating in the 'ratings' subcollection
      transaction.set(userRatingRef, {
        'userId': userId,
        'rating': newRating,
        'timestamp': FieldValue.serverTimestamp(), // Records when the rating was made/updated
      });
    });
  }

  // --- NEW METHOD TO GET USER'S INDIVIDUAL RATING ---
  Stream<double> getUserRecipeRatingStream({
    required String recipeId,
    required String userId,
  }) {
    return _recipesRef
        .doc(recipeId)
        .collection('ratings')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('rating')) {
        return (doc.data()!['rating'] as num).toDouble();
      }
      return 0.0; // Return 0.0 if the user has not rated this recipe yet
    });
  }
}