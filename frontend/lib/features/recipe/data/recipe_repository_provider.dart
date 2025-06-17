// lib/features/recipe/providers/recipe_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart'; // Ensure this path is correct
import '../data/firestore_recipe_datasource.dart';
import '../domain/recipe_entity.dart';
import 'recipe_repository.dart';
import 'dart:developer'; // Import for log() function

/// 1. Data source provider
final recipeDataSourceProvider = Provider<FirestoreRecipeDataSource>((ref) {
  log('Provider: recipeDataSourceProvider - Initialized');
  return FirestoreRecipeDataSource();
});

/// 2. Repository provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final dataSource = ref.read(recipeDataSourceProvider);
  log('Provider: recipeRepositoryProvider - Initialized with DataSource');
  return RecipeRepository(dataSource);
});

// --- NEW/MODIFIED TOP-LEVEL RECIPE PROVIDERS FOR SPECIFIC PAGES ---

/// Provider for ALL public recipes (both Yummify and user-contributed public ones).
/// This might not be directly used by a specific page, but can be a base.
/// If you need a page that shows absolutely ALL public recipes, this is it.
final allPublicRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  log('Provider: allPublicRecipesProvider - Fetching all recipes...');
  final repo = ref.read(recipeRepositoryProvider);
  final allRecipes = await repo.getRecipes();
  log('Provider: allPublicRecipesProvider - Fetched ${allRecipes.length} recipes.');

  final filteredRecipes = allRecipes.where((r) {
    final isPublic = r.visibility == 'public';
    log('  Recipe Name: ${r.name}, ID: ${r.id}, Visibility: ${r.visibility} (isPublic: $isPublic)');
    return isPublic;
  }).toList();

  log('Provider: allPublicRecipesProvider - Filtered to ${filteredRecipes.length} public recipes.');
  return filteredRecipes;
});

/// Provider for "All Recipes Page" - YUMMIFY OFFICIAL RECIPES
/// Assumes Yummify recipes have `role` NOT equal to 'user' (e.g., 'admin', 'yummify_official')
/// OR that they are identifiable by `createdBy` (e.g., 'Yummify').
/// I'll use `role != 'user'` as it's common for admin/official content.
final yummifyRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  log('Provider: yummifyRecipesProvider - Fetching recipes for Yummify page...');
  final repo = ref.read(recipeRepositoryProvider);
  final allRecipes = await repo.getRecipes(); // This fetches ALL recipes
  log('Provider: yummifyRecipesProvider - Fetched ${allRecipes.length} raw recipes.');

  final filteredRecipes = allRecipes.where((r) {
    final isPublic = r.visibility == 'public';
    final isNotUserRole = r.role != 'user'; // This assumes Yummify recipes have a 'role' other than 'user'
    log('  Recipe Name: ${r.name}, ID: ${r.id}, Visibility: ${r.visibility} (isPublic: $isPublic), Role: ${r.role} (isNotUserRole: $isNotUserRole)');
    return isPublic && isNotUserRole;
  }).toList();

  log('Provider: yummifyRecipesProvider - Filtered to ${filteredRecipes.length} Yummify recipes.');
  return filteredRecipes;
});

/// Provider for "Community Page" - PUBLIC USER-CONTRIBUTED RECIPES
/// This is exactly what your `publicUserRecipesProvider` already does.
/// Renaming for clarity if `recipesProvider` was ambiguous.
final publicCommunityRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  log('Provider: publicCommunityRecipesProvider - Fetching recipes for Community page...');
  final repo = ref.read(recipeRepositoryProvider);
  final allRecipes = await repo.getRecipes(); // This fetches ALL recipes
  log('Provider: publicCommunityRecipesProvider - Fetched ${allRecipes.length} raw recipes.');

  final filteredRecipes = allRecipes.where((r) {
    final isPublic = r.visibility == 'public';
    final isUserRole = r.role == 'user';
    log('  Recipe Name: ${r.name}, ID: ${r.id}, Visibility: ${r.visibility} (isPublic: $isPublic), Role: ${r.role} (isUserRole: $isUserRole)');
    return isPublic && isUserRole;
  }).toList();

  log('Provider: publicCommunityRecipesProvider - Filtered to ${filteredRecipes.length} community recipes.');
  return filteredRecipes;
});

/// Provider for "My Recipes Page" - Recipes created by the current logged-in user (public or private)
/// This needs the current user's ID.
// final myRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
//   log('Provider: myRecipesProvider - Fetching recipes for My Recipes page...');
//   final repo = ref.read(recipeRepositoryProvider);
//   final userId = await ref.watch(userIdProvider.future); // Get current user ID
//
//   if (userId == null) {
//     log('Provider: myRecipesProvider - No user logged in, returning empty list.');
//     return [];
//   }
//   log('Provider: myRecipesProvider - Current User ID: $userId');
//
//   final allRecipes = await repo.getRecipes(); // This fetches ALL recipes
//   log('Provider: myRecipesProvider - Fetched ${allRecipes.length} raw recipes.');
//
//   final filteredRecipes = allRecipes.where((r) {
//     final isMyRecipe = r.writer == userId;
//     log('  Recipe Name: ${r.name}, ID: ${r.id}, Writer: ${r.writer} (isMyRecipe: $isMyRecipe)');
//     return isMyRecipe;
//   }).toList();
//
//   log('Provider: myRecipesProvider - Filtered to ${filteredRecipes.length} user recipes.');
//   return filteredRecipes;
// });


// --- DEPENDENT PROVIDERS (NOW WATCHING THE CORRECT BASE PROVIDER) ---

/// 3. Filtered by cuisine (now based on publicCommunityRecipesProvider for community content)
/// If this is for community content. If for Yummify content, watch `yummifyRecipesProvider`.
final communityRecipesByCuisineProvider = FutureProvider.family<List<RecipeEntity>, String>((ref, cuisine) async {
  log('Provider: communityRecipesByCuisineProvider - Fetching cuisine: $cuisine from community recipes...');
  final allRecipesAsync = ref.watch(publicCommunityRecipesProvider); // WATCHING THE CORRECT PROVIDER

  return allRecipesAsync.when(
    data: (recipes) {
      log('Provider: communityRecipesByCuisineProvider - Received ${recipes.length} community recipes for cuisine filter.');
      final filtered = recipes.where((r) {
        final matchesCuisine = r.cuisine.toLowerCase() == cuisine.toLowerCase();
        log('  Recipe Name: ${r.name}, ID: ${r.id}, Cuisine: ${r.cuisine} (matches: $matchesCuisine)');
        return matchesCuisine;
      }).toList();
      log('Provider: communityRecipesByCuisineProvider - Filtered to ${filtered.length} recipes for cuisine: $cuisine.');
      return filtered;
    },
    loading: () {
      log('Provider: communityRecipesByCuisineProvider - Loading community recipes for cuisine: $cuisine.');
      return [];
    },
    error: (err, stack) {
      log('Provider: communityRecipesByCuisineProvider - Error loading community recipes for cuisine: $cuisine. Error: $err');
      return [];
    },
  );
});

/// 4. New recipes (now based on publicCommunityRecipesProvider for community content)
/// If this is for community content. If for Yummify content, watch `yummifyRecipesProvider`.
final newCommunityRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  log('Provider: newCommunityRecipesProvider - Fetching new community recipes...');
  final allRecipesAsync = ref.watch(publicCommunityRecipesProvider); // WATCHING THE CORRECT PROVIDER
  return allRecipesAsync.when(
    data: (recipes) {
      log('Provider: newCommunityRecipesProvider - Received ${recipes.length} community recipes for new recipes filter.');
      final sorted = [...recipes];
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final taken = sorted.take(10).toList(); // show 10 latest
      log('Provider: newCommunityRecipesProvider - Sorted and took ${taken.length} latest recipes.');
      return taken;
    },
    loading: () {
      log('Provider: newCommunityRecipesProvider - Loading community recipes for new recipes.');
      return [];
    },
    error: (err, stack) {
      log('Provider: newCommunityRecipesProvider - Error loading community recipes for new recipes. Error: $err');
      return [];
    },
  );
});

/// 5. Featured (Top rated) (now based on publicCommunityRecipesProvider for community content)
/// If this is for community content. If for Yummify content, watch `yummifyRecipesProvider`.
final featuredCommunityRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  log('Provider: featuredCommunityRecipesProvider - Fetching featured community recipes...');
  final allRecipesAsync = ref.watch(publicCommunityRecipesProvider); // WATCHING THE CORRECT PROVIDER
  return allRecipesAsync.when(
    data: (recipes) {
      log('Provider: featuredCommunityRecipesProvider - Received ${recipes.length} community recipes for featured filter.');
      final sorted = [...recipes];
      sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating)); // Sort by averageRating
      final taken = sorted.take(10).toList();
      log('Provider: featuredCommunityRecipesProvider - Sorted and took ${taken.length} featured recipes.');
      return taken;
    },
    loading: () {
      log('Provider: featuredCommunityRecipesProvider - Loading community recipes for featured recipes.');
      return [];
    },
    error: (err, stack) {
      log('Provider: featuredCommunityRecipesProvider - Error loading community recipes for featured recipes. Error: $err');
      return [];
    },
  );
});

// --- REMAINING PROVIDERS (NO CHANGE NECESSARY) ---

/// Provider for a single recipe's real-time updates
/// It takes a recipe ID as an argument.
final singleRecipeProvider = StreamProvider.family<RecipeEntity, String>((ref, recipeId) {
  log('Provider: singleRecipeProvider - Watching recipe ID: $recipeId');
  final repo = ref.read(recipeRepositoryProvider);
  return repo.getRecipeStream(recipeId);
});

/// Provider for the current user's rating for a specific recipe.
/// Returns a Stream<double> which will be 0.0 if not rated.
final userRecipeRatingProvider = StreamProvider.family<double, String>((ref, recipeId) {
  log('Provider: userRecipeRatingProvider - Checking rating for recipe ID: $recipeId');
  final userIdAsyncValue = ref.watch(userIdProvider); // Get current user ID (AsyncValue)

  // Watch for changes in userIdAsyncValue
  return userIdAsyncValue.when(
    data: (userId) {
      if (userId == null) {
        log('Provider: userRecipeRatingProvider - No user logged in, rating 0.0 for $recipeId');
        return Stream.value(0.0);
      }
      log('Provider: userRecipeRatingProvider - User ID: $userId, getting rating for $recipeId');
      // If user is logged in, get their specific rating from the repository
      final repo = ref.read(recipeRepositoryProvider);
      return repo.getUserRecipeRatingStream(recipeId: recipeId, userId: userId);
    },
    loading: () {
      log('Provider: userRecipeRatingProvider - Loading user ID for rating $recipeId');
      return Stream.value(0.0); // While loading user ID, assume 0.0 rating
    },
    error: (err, stack) {
      log('Provider: userRecipeRatingProvider - Error getting user ID for rating $recipeId. Error: $err');
      return Stream.value(0.0); // On error getting user ID, assume 0.0
    },
  );
});