import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/recipe_repository_provider.dart';
import '../../domain/recipe_entity.dart';
import 'recipedetail_screen.dart';

class CuisinesScreen extends ConsumerWidget {
  final String cuisine;

  const CuisinesScreen({super.key, required this.cuisine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(yummifyRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("$cuisine Recipes"),
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (recipes) {
          final cuisineRecipes =
          recipes.where((r) => r.cuisine == cuisine).toList();

          return Column(
            children: [
              const SizedBox(height: 8),
              _buildFilterChips(), // Optional (you can wire these later)
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cuisineRecipes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final recipe = cuisineRecipes[index];
                    return _RecipeCardMini(recipe: recipe);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          FilterChip(label: const Text("High Protein"), onSelected: (_) {}),
          const SizedBox(width: 8),
          FilterChip(label: const Text("Low Carb"), onSelected: (_) {}),
          const SizedBox(width: 8),
          FilterChip(label: const Text("Under 30 min"), onSelected: (_) {}),
        ],
      ),
    );
  }
}

class _RecipeCardMini extends StatelessWidget {
  final RecipeEntity recipe;

  const _RecipeCardMini({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                recipe.img,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(recipe.review.toStringAsFixed(1)),
                ],
              ),
            ),
            if (recipe.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  recipe.tags.first,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.brown,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
