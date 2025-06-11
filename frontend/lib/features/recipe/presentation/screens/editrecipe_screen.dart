import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/recipe_repository.dart';
import '../../domain/recipe_entity.dart';

class EditRecipeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const EditRecipeScreen({super.key, required this.recipeId});

  @override
  ConsumerState<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends ConsumerState<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  bool _isPublic = true;
  bool _loading = true;

  late RecipeEntity _recipe;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _ingredientsController = TextEditingController();
    _stepsController = TextEditingController();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final repo = ref.read(recipeRepositoryProvider);
    final recipe = await repo.getRecipeById(widget.recipeId);

    setState(() {
      _recipe = recipe;
      _titleController.text = recipe.title;
      _descriptionController.text = recipe.description;
      _ingredientsController.text = recipe.ingredients.join(', ');
      _stepsController.text = recipe.steps.join(', ');
      _isPublic = recipe.isPublic;
      _loading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedRecipe = RecipeEntity(
        id: _recipe.id,
        title: _titleController.text,
        description: _descriptionController.text,
        ingredients: _ingredientsController.text.split(',').map((e) => e.trim()).toList(),
        steps: _stepsController.text.split(',').map((e) => e.trim()).toList(),
        isPublic: _isPublic,
        createdBy: _recipe.createdBy,
        likedBy: _recipe.likedBy,
        bookmarkedBy: _recipe.bookmarkedBy,
      );

      await ref.read(recipeRepositoryProvider).updateRecipe(updatedRecipe);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredients (comma-separated)'),
              ),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(labelText: 'Steps (comma-separated)'),
              ),
              SwitchListTile(
                title: const Text('Make recipe public'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
