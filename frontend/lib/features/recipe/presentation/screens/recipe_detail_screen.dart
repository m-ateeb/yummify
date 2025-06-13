
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/recipe_repository.dart';
//import '../../data/recipe_repository.dart'; // Where recipeByIdProvider is defined
import '../../domain/recipe_entity.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));
    final recipeRepo = ref.read(recipeRepositoryProvider);

    return recipeAsync.when(
      data: (recipe) => Scaffold(
        appBar: AppBar(title: Text(recipe.title)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Text('🧂 Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...recipe.ingredients.map((i) => Text('- $i')).toList(),
              const SizedBox(height: 16),
              const Text('👨‍🍳 Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...recipe.steps.map((s) => Text('• $s')).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await recipeRepo.toggleLike(recipe.id, 'userId'); // TODO: Replace with actual user ID
                  ref.refresh(recipeByIdProvider(recipeId)); // Refresh to reflect like change
                },
                child: Text(recipe.likedBy.contains('userId') ? '❤️ Unlike' : '🤍 Like'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await recipeRepo.toggleBookmark(recipe.id, 'userId'); // TODO: Replace with actual user ID
                  ref.refresh(recipeByIdProvider(recipeId)); // Refresh to reflect bookmark change
                },
                child: Text(recipe.bookmarkedBy.contains('userId') ? '🔖 Unbookmark' : '📌 Bookmark'),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Something went wrong: $error')),
      ),
    );
  }
}
