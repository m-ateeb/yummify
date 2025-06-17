import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/recipe_entity.dart';
import '../../data/recipe_repository_provider.dart'; // Make sure this points to recipe_providers.dart

import 'recipe_builder_page.dart'; // Import the AI Recipe Builder Page
import 'createrecipe_screen.dart';
import 'recipedetail_screen.dart';
import 'cuisines_screen.dart'; // Make sure this page can filter by cuisine
import 'dart:math'; // For random selection of cuisines

class AllRecipesScreen extends ConsumerStatefulWidget {
  const AllRecipesScreen({super.key});

  @override
  ConsumerState<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends ConsumerState<AllRecipesScreen> with TickerProviderStateMixin {
  // State for the cuisine filter (still needed for the ChoiceChips if we use them later)
  String _selectedCuisineFilter = 'All'; // Not directly used for filtering content on this specific page anymore, but good to keep if you want to reuse the chip logic for other purposes later.

  final List<String> allCuisineCategories = [
    'Italian', 'Mexican', 'Indian', 'Asian', 'Japanese',
    'French', 'American', 'Mediterranean', 'Other' // 'All' is handled separately for display
  ];

  late AnimationController _cardEnterController;
  late Animation<double> _cardEnterAnimation;

  @override
  void initState() {
    super.initState();
    _cardEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardEnterAnimation = CurvedAnimation(parent: _cardEnterController, curve: Curves.easeOut);
    _cardEnterController.forward();
  }

  @override
  void dispose() {
    _cardEnterController.dispose();
    super.dispose();
  }

  // --- Cuisine Filter Chips (kept, but for future use or if you want to place them visually) ---
  Widget _buildCuisineFilterChips(List<String> categories) {
    return SizedBox(
      height: 50, // Height for the horizontal chips
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCuisineFilter == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: Colors.black, // Monochromatic selected color
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCuisineFilter = category;
                    // This state change is primarily visual on this page.
                    // For actual filtering, you'd navigate to CuisinesScreen.
                  });
                }
              },
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the yummifyRecipesProvider for the main data source
    final recipesAsync = ref.watch(yummifyRecipesProvider);

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        backgroundColor: Colors.white, // White app bar
        elevation: 0, // No shadow for a minimal look
        title: const Text(
          "Explore Recipes",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Dark text
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87), // Dark icon
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)), // Black loading indicator
        ),
        error: (e, _) => Center(
          child: Text(
            "Error loading recipes: $e",
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        data: (recipes) {
          // Ensure we have enough recipes for all sections
          if (recipes.isEmpty) {
            return const Center(
              child: Text(
                'No recipes available. Try generating one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final Random random = Random();

          // Featured recipes: top 10 by average rating
          final featured = recipes.sorted((a, b) => b.averageRating.compareTo(a.averageRating)).take(10).toList();

          // Select 3 random cuisines to showcase
          final List<String> selectedRandomCuisines = [];
          if (allCuisineCategories.length > 3) {
            final List<String> shuffledCuisines = List.from(allCuisineCategories)..shuffle(random);
            selectedRandomCuisines.addAll(shuffledCuisines.take(3));
          } else {
            selectedRandomCuisines.addAll(allCuisineCategories);
          }

          // New recipes: latest 10 by creation date
          final newRecipes = recipes.sorted((a, b) => b.createdAt.compareTo(a.createdAt)).take(10).toList();

          return FadeTransition(
            opacity: _cardEnterAnimation,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Featured Recipes Section
                _sectionTitle("Featured Picks"),
                _horizontalRecipeList(context, featured),
                const SizedBox(height: 24),

                // Browse by Cuisine Grid (Selectors)
                _sectionTitle("Browse by Cuisine"),
                _cuisineGrid(context, allCuisineCategories),
                const SizedBox(height: 24),

                // Randomly Selected Cuisine Lists
                ...selectedRandomCuisines.map((cuisine) {
                  final cuisineRecipes = recipes.where((r) => r.cuisine == cuisine).take(6).toList(); // Keeping 6 for random cuisine lists to prevent excessive scrolling
                  if (cuisineRecipes.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("$cuisine Delights"),
                        _horizontalRecipeList(context, cuisineRecipes),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink(); // Hide if no recipes for this cuisine
                }).toList(),

                // New Recipes Section
                _sectionTitle("Freshly Added"),
                _horizontalRecipeList(context, newRecipes),
                const SizedBox(height: 24),

                // Create Your Own Recipe Card
                _createYourOwnCard(context),
                const SizedBox(height: 16),

                // Build Your Recipe with AI Button
                _buildWithAIButton(context),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0), // More vertical padding
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800, // Extra bold for emphasis
        color: Colors.black87,
        fontFamily: 'Montserrat',
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _horizontalRecipeList(BuildContext context, List<RecipeEntity> recipes) => SizedBox(
    height: 250,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        // Ensure averageRating is clamped between 0.0 and 5.0 before display
        final displayRating = recipe.averageRating.clamp(0.0, 5.0);

        return GestureDetector(
          onTap: () {
            // HapticFeedback.lightImpact(); // Optional: Add haptic feedback
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
            );
          },
          child: Hero(
            tag: 'recipe-${recipe.id}',
            child: Container( // Changed from AnimatedContainer for simplicity, but you can re-add if needed
              width: 180,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white, // White card background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1), // Subtle border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), // Lighter shadow
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      recipe.img,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 140,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.black, size: 18), // Black star
                            const SizedBox(width: 4),
                            Text(
                              displayRating.toStringAsFixed(1), // Use the clamped value here
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.access_time, color: Colors.black, size: 16), // Black clock
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.totaltime}m',
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _cuisineGrid(BuildContext context, List<String> cuisines) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(), // Important for nested scroll views
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 2.5, // Wider buttons
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: cuisines.length,
    itemBuilder: (context, index) {
      final cuisine = cuisines[index];
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CuisinesScreen(cuisine: cuisine)),
          );
        },
        icon: Icon(Icons.restaurant_menu, color: Colors.black87), // Black icon
        label: Text(
          cuisine,
          style: TextStyle(
            color: Colors.black87, // Dark text
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100], // Light grey background
          shadowColor: Colors.black.withOpacity(0.1), // Subtle shadow
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300, width: 1), // Subtle border
          ),
        ),
      );
    },
  );

  Widget _createYourOwnCard(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRecipeScreen()),
    ),
    child: Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black, // Solid black background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "🧑‍🍳 Craft Your Own Recipe!",
          style: TextStyle(
            color: Colors.white, // White text
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );

  Widget _buildWithAIButton(BuildContext context) => ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecipeBuilderPage()),
      );
    },
    icon: const Icon(Icons.psychology_alt, size: 28, color: Colors.white), // White icon
    label: const Text(
      "Build Your Recipe with AI",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
        color: Colors.white, // White text
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black87, // Dark grey/black button
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.5),
    ),
  );
}

// Extension to sort lists (already provided)
extension _Sort on List<RecipeEntity> {
  List<RecipeEntity> sorted(int Function(RecipeEntity, RecipeEntity) compare) {
    final copy = [...this];
    copy.sort(compare);
    return copy;
  }
}