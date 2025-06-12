import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/recipe_repository.dart';
import '../../domain/recipe_entity.dart';

class CreateRecipeScreen extends ConsumerWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeRepository = ref.watch(recipeRepositoryProvider);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final ingredientsController = TextEditingController();
    final stepsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: ingredientsController, decoration: const InputDecoration(labelText: 'Ingredients')),
            TextField(controller: stepsController, decoration: const InputDecoration(labelText: 'Steps')),
            ElevatedButton(
              onPressed: () async {
                final newRecipe = RecipeEntity(
                  id: '', // Firestore will generate this
                  title: titleController.text,
                  description: descriptionController.text,
                  ingredients: ingredientsController.text.split(','),
                  steps: stepsController.text.split(','),
                  isPublic: true,
                  createdBy: 'userId', // Replace with actual user ID
                  likedBy: [],
                  bookmarkedBy: [],
                );
                await recipeRepository.createRecipe(newRecipe);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
