// lib/features/recipe/providers/recipe_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart'; // Ensure this path is correct
import '../data/firestore_recipe_datasource.dart';
import '../domain/recipe_entity.dart';
import 'recipe_repository.dart';

// IMPORTANT: Review if 'recipesProvider' is used elsewhere.
// If it's *only* meant for community recipes, it should also filter by role 'user'.
// If it's meant for *all* public recipes (including admin/yummify), then the name
// is fine, but you must ensure your community page only uses publicUserRecipesProvider.
// For clarity and to fix the current issue, let's make it consistent for community page needs.
final recipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  final repo = ref.read(recipeRepositoryProvider);
  final all = await repo.getRecipes();
  // Ensure this also filters for role 'user' if this provider is also intended
  // for displaying community recipes in other parts of the app.
  // If 'recipesProvider' is intended for ALL public recipes (admin, yummify, user),
  // then leave this as it is and ensure only publicUserRecipesProvider is used
  // for the community screen.
  // For now, I'm assuming it's for *all* public recipes.
  return all.where((r) => r.status == 'public').toList();
});

/// 1. Data source provider
final recipeDataSourceProvider = Provider<FirestoreRecipeDataSource>((ref) {
  return FirestoreRecipeDataSource();
});

/// 2. Repository provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final dataSource = ref.read(recipeDataSourceProvider);
  return RecipeRepository(dataSource);
});

/// 3. All public and user-role recipes
// This is the correct source for community recipes.
final publicUserRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  final repo = ref.read(recipeRepositoryProvider);
  final recipes = await repo.getRecipes();
  // Filter for public AND user-role recipes - THIS IS THE KEY FILTER
  return recipes.where((r) => r.status == 'public' && r.role == 'user').toList();
});

/// 4. Filtered by cuisine (now based on publicUserRecipesProvider)
final recipesByCuisineProvider = FutureProvider.family<List<RecipeEntity>, String>((ref, cuisine) async {
  final allRecipesAsync = ref.watch(publicUserRecipesProvider); // WATCHING THE CORRECT PROVIDER
  return allRecipesAsync.when(
    data: (recipes) =>
        recipes.where((r) => r.cuisine.toLowerCase() == cuisine.toLowerCase()).toList(),
    loading: () => [],
    error: (err, stack) => [],
  );
});

/// 5. New recipes (now based on publicUserRecipesProvider)
final newRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  final allRecipesAsync = ref.watch(publicUserRecipesProvider); // WATCHING THE CORRECT PROVIDER
  return allRecipesAsync.when(
    data: (recipes) {
      final sorted = [...recipes];
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted.take(10).toList(); // show 10 latest
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

/// 6. Featured (Top rated) (now based on publicUserRecipesProvider)
final featuredRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  final allRecipesAsync = ref.watch(publicUserRecipesProvider); // WATCHING THE CORRECT PROVIDER
  return allRecipesAsync.when(
    data: (recipes) {
      final sorted = [...recipes];
      sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating)); // Sort by averageRating
      return sorted.take(10).toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

/// Provider for a single recipe's real-time updates
/// It takes a recipe ID as an argument.
final singleRecipeProvider = StreamProvider.family<RecipeEntity, String>((ref, recipeId) {
  final repo = ref.read(recipeRepositoryProvider);
  return repo.getRecipeStream(recipeId);
});

/// Provider for the current user's rating for a specific recipe.
/// Returns a Stream<double> which will be 0.0 if not rated.
final userRecipeRatingProvider = StreamProvider.family<double, String>((ref, recipeId) {
  final userIdAsyncValue = ref.watch(userIdProvider); // Get current user ID (AsyncValue)

  // Watch for changes in userIdAsyncValue
  return userIdAsyncValue.when(
    data: (userId) {
      if (userId == null) {
        // If no user is logged in, return a stream that immediately emits 0.0
        return Stream.value(0.0);
      }
      // If user is logged in, get their specific rating from the repository
      final repo = ref.read(recipeRepositoryProvider);
      return repo.getUserRecipeRatingStream(recipeId: recipeId, userId: userId);
    },
    loading: () => Stream.value(0.0), // While loading user ID, assume 0.0 rating
    error: (err, stack) => Stream.value(0.0), // On error getting user ID, assume 0.0
  );
});