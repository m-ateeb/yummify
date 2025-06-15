import 'package:firebase_auth/firebase_auth.dart';
import '../data/firestore_recipe_datasource.dart';
import '../domain/recipe_entity.dart';

class RecipeRepository {
  final FirestoreRecipeDataSource _dataSource;
  final _auth = FirebaseAuth.instance; // Keep this for userId

  final _cache = <String, RecipeEntity>{};
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(seconds: 30);

  RecipeRepository(this._dataSource);

  /// Fetch recipes.
  /// If [onlyMine] is true, fetch only recipes created by the current user.
  Future<List<RecipeEntity>> getRecipes({bool onlyMine = false}) async {
    final now = DateTime.now();

    // Get the current user ID if filtering is needed
    final userId = onlyMine ? _auth.currentUser?.uid : null;

    if (_lastFetchTime == null || now.difference(_lastFetchTime!) > _cacheDuration) {
      final recipes = await _dataSource.getRecipes(userId: userId);
      _cache
        ..clear()
        ..addEntries(recipes.map((r) => MapEntry(r.id, r)));
      _lastFetchTime = now;
      return recipes;
    }

    return _cache.values.toList();
  }

  // Changed to use the Stream-based method from DataSource
  Stream<RecipeEntity> getRecipeStream(String id) {
    // For a real-time stream, caching here is generally not beneficial
    // as the stream provides continuous updates directly from the source.
    return _dataSource.getRecipeStream(id);
  }

  // Renamed from getRecipeById and now uses the Stream for consistency with how detail page works
  // (though the old Future-based getRecipeById could still exist for one-off fetches not needing real-time)
  Future<RecipeEntity> getRecipeById(String id) async {
    // This method still uses the cache and Future-based fetch
    // If you always want real-time for detail screen, use getRecipeStream directly.
    if (_cache.containsKey(id)) {
      return _cache[id]!;
    } else {
      final recipe = await _dataSource.getRecipeById(id);
      _cache[id] = recipe;
      return recipe;
    }
  }


  Future<void> createRecipe(RecipeEntity recipe) async {
    await _dataSource.createRecipe(recipe);
    // Invalidate the cache for all recipes if a new one is added
    clearCache(); // Or update cache more selectively if needed
  }

  Future<void> updateRecipe(RecipeEntity recipe) async {
    await _dataSource.updateRecipe(recipe);
    _cache[recipe.id] = recipe; // Update cache for this specific recipe
    // Note: If you have lists of recipes (e.g., publicRecipesProvider) watching getRecipes,
    // they might need to be invalidated or refetched to reflect updates if they rely on the cache.
  }

  Future<void> deleteRecipe(String id) async {
    await _dataSource.deleteRecipe(id);
    _cache.remove(id); // Remove from cache
    clearCache(); // Invalidate overall cache to ensure lists are fresh
  }

  void clearCache() {
    _cache.clear();
    _lastFetchTime = null;
  }

  // --- NEW METHODS FOR RATING ---

  /// Updates a recipe's rating in the data source.
  Future<void> updateRecipeRating({
    required String recipeId,
    required String userId,
    required double newRating,
    required double? oldRating,
  }) {
    // This delegates directly to the data source which handles Firestore transaction.
    // The relevant RecipeEntity stream in the UI will automatically update.
    return _dataSource.updateRecipeRating(
      recipeId: recipeId,
      userId: userId,
      newRating: newRating,
      oldRating: oldRating,
    );
  }

  /// Provides a stream of the current user's rating for a specific recipe.
  Stream<double> getUserRecipeRatingStream({
    required String recipeId,
    required String userId,
  }) {
    // This delegates directly to the data source as it's a real-time stream.
    return _dataSource.getUserRecipeRatingStream(
      recipeId: recipeId,
      userId: userId,
    );
  }
}