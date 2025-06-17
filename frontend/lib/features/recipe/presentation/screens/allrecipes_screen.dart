import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/recipe_entity.dart';
  import '../../data/recipe_repository_provider.dart';
import 'createrecipe_screen.dart';
import 'recipedetail_screen.dart';
import 'cuisines_screen.dart';

class AllRecipesScreen extends ConsumerWidget {
  const AllRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(yummifyRecipesProvider); // 🧠 Fetch public recipes
    print(recipesAsync.value);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Recipes"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (recipes) {
          final featured = recipes.take(5).toList();
          final cuisines = {
            'Asian': recipes.where((r) => r.cuisine == 'Asian').toList(),
            'Pakistani': recipes.where((r) => r.cuisine == 'Pakistani').toList(),
            'Italian': recipes.where((r) => r.cuisine == 'Italian').toList(),
            'Continental': recipes.where((r) => r.cuisine == 'Continental').toList(),
          };
          final newRecipes = recipes
              .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
              .take(6)
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _sectionTitle("Featured Recipes"),
              _horizontalList(context, featured),
              const SizedBox(height: 16),
              _sectionTitle("Browse by Cuisine"),
              _cuisineGrid(context, cuisines.keys.toList()),
              const SizedBox(height: 16),
              ...cuisines.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("${entry.key} Cuisine"),
                  _horizontalList(context, entry.value),
                  const SizedBox(height: 16),
                ],
              )),
              _sectionTitle("New Recipes"),
              _horizontalList(context, newRecipes),
              const SizedBox(height: 24),
              _createYourOwnCard(context),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  );

  Widget _horizontalList(BuildContext context, List<RecipeEntity> recipes) => SizedBox(
    height: 230,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
          ),
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(recipe.img),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  recipe.name,
                  style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _cuisineGrid(BuildContext context, List<String> cuisines) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    childAspectRatio: 3,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    children: cuisines
        .map((cuisine) => ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CuisinesScreen(cuisine: cuisine)),
        );
      },
      icon: const Icon(Icons.restaurant_menu),
      label: Text(cuisine),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent.shade100,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ))
        .toList(),
  );

  Widget _createYourOwnCard(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRecipeScreen()),
    ),
    child: Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.deepOrange, Colors.orangeAccent]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: const Center(
        child: Text(
          "🍳 Create Your Own Recipe!",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

extension _Sort on List<RecipeEntity> {
  List<RecipeEntity> sorted(int Function(RecipeEntity, RecipeEntity) compare) {
    final copy = [...this];
    copy.sort(compare);
    return copy;
  }
}
