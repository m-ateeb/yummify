import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/recipe_repository_provider.dart'; // Ensure this points to recipe_providers.dart
import '../../domain/recipe_entity.dart';
import 'recipedetail_screen.dart'; // To navigate to individual recipe details

class CuisinesScreen extends ConsumerStatefulWidget {
  final String cuisine;

  const CuisinesScreen({super.key, required this.cuisine});

  @override
  ConsumerState<CuisinesScreen> createState() => _CuisinesScreenState();
}

class _CuisinesScreenState extends ConsumerState<CuisinesScreen> with SingleTickerProviderStateMixin {
  // Animation for content fading in
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Placeholder for filter selection (you can expand this later)
  String _selectedFilter = 'All'; // Example: 'All', 'High Protein', 'Low Carb', 'Under 30 min'

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
    // Watch the provider that filters recipes by the specific cuisine
    // Assuming 'communityRecipesByCuisineProvider' fetches recipes for a given cuisine.
    // If you want official 'yummify' recipes for a cuisine, you'd need a similar provider like 'yummifyRecipesByCuisineProvider'.
    final recipesAsync = ref.watch(communityRecipesByCuisineProvider(widget.cuisine));

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        backgroundColor: Colors.white, // White app bar
        elevation: 0, // No shadow for a minimal look
        title: Text(
          "${widget.cuisine} Recipes",
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Dark text
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87), // Dark back arrow
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: recipesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)), // Black loading indicator
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Error loading ${widget.cuisine} recipes: $e\nPlease try again.",
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (cuisineRecipes) {
          if (cuisineRecipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No ${widget.cuisine} recipes found. How about exploring other cuisines?',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontFamily: 'Montserrat'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Filter Chips Section (Monochromatic style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildFilterChips(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16), // Increased padding
                    itemCount: cuisineRecipes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16, // Increased spacing
                      mainAxisSpacing: 16, // Increased spacing
                      childAspectRatio: 0.72, // Adjusted for better card fit
                    ),
                    itemBuilder: (context, index) {
                      final recipe = cuisineRecipes[index];
                      return _RecipeCardMini(recipe: recipe);
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

  // --- Monochromatic Filter Chips ---
  Widget _buildFilterChips() {
    final List<String> filterOptions = [
      'All', // Add 'All' option for filters
      'High Protein',
      'Low Carb',
      'Under 30 min',
      // Add more filters here as needed
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
              selectedColor: Colors.black, // Monochromatic selected color
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                    // TODO: Implement actual filtering logic here based on _selectedFilter
                    // This would likely involve passing the filter to your Riverpod provider
                    // or re-filtering the 'cuisineRecipes' list locally.
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
        }).toList(),
      ),
    );
  }
}

// --- RecipeCardMini (Adapted for monochromatic theme and better info display) ---
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
      child: Hero(
        tag: 'recipe-${recipe.id}', // Ensure unique tag
        child: Container(
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
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  recipe.img,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0), // Slightly adjusted padding
                child: Text(
                  recipe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Dark text
                    fontFamily: 'Montserrat',
                    fontSize: 15, // Slightly smaller for dense grid
                  ),
                ),
              ),
              const Spacer(), // Pushes content to top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.black, size: 18), // Black star
                    const SizedBox(width: 4),
                    Text(
                      recipe.averageRating.toStringAsFixed(1), // Use averageRating
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
              ),
              // Removed the single tag display, as it might not always be useful or present
              // and to keep the card cleaner for the monochromatic theme.
              const SizedBox(height: 8), // Add some bottom padding
            ],
          ),
        ),
      ),
    );
  }
}