// lib/features/recipe/presentation/widgets/recipe_tile_card.dart

import 'package:flutter/material.dart';
import '../../domain/recipe_entity.dart';
import '../screens/recipedetail_screen.dart'; // Import your RecipeDetailScreen

class RecipeTileCard extends StatelessWidget {
  final RecipeEntity recipe;
  final bool isHorizontal; // To adjust layout for horizontal lists

  const RecipeTileCard({
    Key? key,
    required this.recipe,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Updated navigation to use Navigator.push and pass the RecipeEntity object
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      child: Container(
        width: isHorizontal ? 180 : double.infinity, // Fixed width for horizontal
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: isHorizontal
            ? _buildHorizontalLayout()
            : _buildVerticalLayout(),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            recipe.img,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                height: 120,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber[600], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    recipe.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.timer_outlined, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.totaltime} min',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              recipe.img,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[600], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      recipe.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer_outlined, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.totaltime} min',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.cuisine,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}