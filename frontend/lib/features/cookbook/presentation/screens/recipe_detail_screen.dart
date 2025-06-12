import 'package:flutter/material.dart';
import '/features/cookbook/domain/cookbook_entity.dart';

class RecipeDetailScreen extends StatelessWidget {
  final CookbookEntity recipe;

  const RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.imageUrl),
            const SizedBox(height: 16.0),
            Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // Add more details here
          ],
        ),
      ),
    );
  }
}
