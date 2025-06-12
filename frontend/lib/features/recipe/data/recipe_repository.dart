import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_recipe_datasource.dart';
import '../domain/recipe_entity.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(firestoreRecipeDataSourceProvider));
});
final recipeByIdProvider = FutureProvider.family<RecipeEntity, String>((ref, recipeId) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipeById(recipeId);
});

class RecipeRepository {
  final FirestoreRecipeDataSource _dataSource;
  final _cache = <String, RecipeEntity>{};
  DateTime? _lastFetchTime;
  static const _fetchInterval = Duration(seconds: 30); // Rate limit interval

  RecipeRepository(this._dataSource);

  Future<List<RecipeEntity>> getRecipes({String? userId}) async {
    final now = DateTime.now();
    if (_lastFetchTime == null || now.difference(_lastFetchTime!) > _fetchInterval) {
      _lastFetchTime = now;
      final recipes = await _dataSource.getRecipes(userId: userId);
      _cache.addEntries(recipes.map((e) => MapEntry(e.id, e)));
      return recipes;
    } else {
      return _cache.values.toList();
    }
  }

  Future<RecipeEntity> getRecipeById(String id) async {
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
  }
  Future<void> deleteRecipe(String recipeId) async {
    await _dataSource.deleteRecipe(recipeId);
    _invalidateCache(recipeId);
  }
  Future<void> updateRecipe(RecipeEntity updatedRecipe) async {
    await _dataSource.updateRecipe(updatedRecipe);
    _invalidateCache(updatedRecipe.id);
  }

  Future<void> toggleLike(String recipeId, String userId) async {
    await _dataSource.toggleLike(recipeId, userId);
    _invalidateCache(recipeId);
  }

  Future<void> toggleBookmark(String recipeId, String userId) async {
    await _dataSource.toggleBookmark(recipeId, userId);
    _invalidateCache(recipeId);
  }

  void _invalidateCache(String recipeId) {
    _cache.remove(recipeId);
  }
}
