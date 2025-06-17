// lib/features/recipe/presentation/pages/community_recipe_screen.dart


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Assuming you use go_router for navigation
import 'package:shimmer/shimmer.dart'; // For loading effect

import '../../domain/recipe_entity.dart';
import '../../data/recipe_repository_provider.dart'; // Adjust path
import '../widget/recipe_tile_card.dart'; // We'll create this next
class CommunityRecipeScreen extends ConsumerStatefulWidget {
  const CommunityRecipeScreen({super.key});

  @override
  ConsumerState<CommunityRecipeScreen> createState() => _CommunityRecipeScreenState();
}

class _CommunityRecipeScreenState extends ConsumerState<CommunityRecipeScreen> {
  String _selectedCuisineFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Watch the providers for different recipe lists
    final featuredRecipesAsync = ref.watch(featuredCommunityRecipesProvider);
    final newRecipesAsync = ref.watch(newCommunityRecipesProvider);

    // Watch the cuisine filtered recipes
    final recipesByCuisineAsync = ref.watch(communityRecipesByCuisineProvider(_selectedCuisineFilter));

    final List<String> cuisineCategories = [
      'All', 'Italian', 'Mexican', 'Indian', 'Chinese', 'Japanese', 'Thai',
      'French', 'American', 'Mediterranean', 'Other'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Community Recipes",
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Top Rated Recipes ⭐"),
            // Pass the AsyncValue directly here
            _buildRecipeListSection(featuredRecipesAsync, isHorizontalList: true),
            const SizedBox(height: 24),

            _buildSectionTitle("Newest Additions 🆕"),
            // Pass the AsyncValue directly here
            _buildRecipeListSection(newRecipesAsync, isHorizontalList: true),
            const SizedBox(height: 24),

            _buildSectionTitle("Explore by Cuisine 🌍"),
            _buildCuisineFilterChips(cuisineCategories),
            const SizedBox(height: 16),
            // Pass the AsyncValue directly here
            _buildRecipeListSection(recipesByCuisineAsync, isHorizontalList: false),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
          color: Colors.black87,
        ),
      ),
    );
  }

  // Adjusted parameter name for clarity: 'isHorizontalList'
  Widget _buildRecipeListSection(AsyncValue<List<RecipeEntity>> recipesAsync, {required bool isHorizontalList}) {
    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "No recipes found in this category.",
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          );
        }
        if (!isHorizontalList) { // If it's *not* a horizontal list, it's a vertical one
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RecipeTileCard(recipe: recipes[index], isHorizontal: false), // Explicitly set to false
              );
            },
          );
        } else {
          // Horizontal list for featured/newest
          return SizedBox(
            height: 250, // Fixed height for horizontal scrollable list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: RecipeTileCard(recipe: recipes[index], isHorizontal: true), // Explicitly set to true
                );
              },
            ),
          );
        }
      },
      loading: () => isHorizontalList
          ? _buildHorizontalShimmerList()
          : _buildVerticalShimmerList(),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Error loading recipes: ${error.toString()}",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

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
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCuisineFilter = category;
                  });
                }
              },
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalShimmerList() {
    return SizedBox(
      height: 250, // Same height as the actual list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Show a few shimmer items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: double.infinity, height: 16.0, color: Colors.grey[200]),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 14.0, color: Colors.grey[200]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // Show a few shimmer items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120, // Height for vertical list item shimmer
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}