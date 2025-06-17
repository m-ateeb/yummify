import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/recipe/data/recipe_repository_provider.dart'; // Adjust path if needed
import 'package:frontend/features/recipe/domain/recipe_entity.dart';
import 'package:frontend/features/recipe/presentation/screens/recipedetail_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/edit_my_recipe_screen.dart'; // NEW: Import the edit screen
import 'package:frontend/features/recipe/data/recipe_repository_provider.dart'; // Assuming myRecipesProvider is here

class MyRecipesScreen extends ConsumerStatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  ConsumerState<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends ConsumerState<MyRecipesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // You can keep filter options if you want to filter MY recipes, or remove if not needed.
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider for recipes created by the current user
    final myRecipesAsync = ref.watch(myRecipesProvider);

    // Define monochromatic colors for consistency
    const Color primaryBlack = Color(0xFF000000);
    const Color primaryWhite = Color(0xFFFFFFFF);
    const Color greyLight = Color(0xFFF5F5F5);
    const Color greyMedium = Color(0xFFE0E0E0);
    const Color greyDarkText = Color(0xFF424242);
    const Color accentGreen = Color(0xFF5A8E5C); // Subtle accent for actions

    return Scaffold(
      backgroundColor: primaryWhite,
      appBar: AppBar(
        backgroundColor: primaryWhite,
        elevation: 0,
        title: const Text(
          "My Recipes",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: primaryBlack,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: myRecipesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryBlack)),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Error loading your recipes: $e\nPlease ensure you are logged in and try again.",
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (userRecipes) {
          if (userRecipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'You haven\'t created any recipes yet. Why not create one?',
                  style: TextStyle(fontSize: 18, color: greyDarkText, fontFamily: 'Montserrat'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Filter Chips Section (Optional - keep if you want to filter user's own recipes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildFilterChips(primaryBlack, primaryWhite, greyLight, greyMedium, greyDarkText),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: userRecipes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.78, // Slightly adjusted for button
                    ),
                    itemBuilder: (context, index) {
                      final recipe = userRecipes[index];
                      return _MyRecipeCard(
                        recipe: recipe,
                        onEdit: () {
                          // Navigate to the edit screen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => EditMyRecipeScreen(recipe: recipe),
                          //   ),
                          // );
                        },
                        onDelete: () {
                          // TODO: Implement delete functionality for this recipe
                          // A confirmation dialog is highly recommended here.
                          // Example: ref.read(recipeRepositoryProvider).deleteRecipe(recipe.id);
                          // After deletion, you'd want to invalidate the provider to refresh the list:
                          // ref.invalidate(myRecipesProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Delete functionality for ${recipe.name} (ID: ${recipe.id})')),
                          );
                        },
                        primaryBlack: primaryBlack,
                        primaryWhite: primaryWhite,
                        greyMedium: greyMedium,
                        accentGreen: accentGreen,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(Color primaryBlack, Color primaryWhite, Color greyLight, Color greyMedium, Color greyDarkText) {
    final List<String> filterOptions = [
      'All',
      'High Protein',
      'Low Carb',
      'Under 30 min',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: primaryBlack,
              labelStyle: TextStyle(
                color: isSelected ? primaryWhite : primaryBlack,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                    // TODO: Re-fetch or filter myRecipesAsync based on _selectedFilter
                  });
                }
              },
              backgroundColor: greyLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? primaryBlack : greyMedium,
                  width: 1.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --- Modified Recipe Card for My Recipes Screen ---
class _MyRecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color primaryBlack;
  final Color primaryWhite;
  final Color greyMedium;
  final Color accentGreen;

  const _MyRecipeCard({
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
    required this.primaryBlack,
    required this.primaryWhite,
    required this.greyMedium,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Hero(
        tag: 'recipe-${recipe.id}', // Ensure unique tag
        child: Container(
          decoration: BoxDecoration(
            color: primaryWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: greyMedium, width: 1),
            boxShadow: [
              BoxShadow(
                color: primaryBlack.withOpacity(0.05),
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
                  height: 100, // Slightly reduced height to make space for buttons
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 4.0),
                child: Text(
                  recipe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBlack,
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: primaryBlack, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      recipe.averageRating.toStringAsFixed(1),
                      style: TextStyle(color: primaryBlack.withOpacity(0.7), fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, color: primaryBlack, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.totaltime}m',
                      style: TextStyle(color: primaryBlack.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Spacer(), // Pushes action buttons to the bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: Icon(Icons.edit, size: 18, color: accentGreen),
                        label: Text(
                          'Edit',
                          style: TextStyle(color: accentGreen, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accentGreen.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}