import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/recipe/data/recipe_repository_provider.dart'; // Make sure this path is correct
import 'package:frontend/features/recipe/domain/recipe_entity.dart';
import 'package:image_picker/image_picker.dart'; // For image selection
import 'dart:io';

import '../../../user/data/firebase_user_service.dart'; // For File

class EditMyRecipeScreen extends ConsumerStatefulWidget {
  final RecipeEntity recipe;

  const EditMyRecipeScreen({super.key, required this.recipe});

  @override
  ConsumerState<EditMyRecipeScreen> createState() => _EditMyRecipeScreenState();
}

class _EditMyRecipeScreenState extends ConsumerState<EditMyRecipeScreen> {
  // --- Controllers for basic fields ---
  late TextEditingController _nameController;
  late TextEditingController _totalTimeController;
  late TextEditingController _cuisineController;
  late TextEditingController _servingDescriptionController;
  late TextEditingController _servingSizeController;
  late TextEditingController _writerController; // Assuming you can edit this

  // --- Local mutable lists for dynamic fields ---
  late List<Ingredient> _editableIngredients;
  late List<InstructionStep> _editableInstructionSteps;
  late List<DescriptionBlock> _editableDescriptionBlocks;
  late List<String> _editableTags; // For managing tags

  // --- For Nutrition ---
  late TextEditingController _caloriesController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  late TextEditingController _proteinController;

  // --- For Image Upload ---
  File? _selectedImageFile;
  String? _currentImageUrl; // To display existing image

  // --- For Visibility (if editable) ---
  late String _selectedVisibility; // 'public', 'private', 'unlisted'

  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing recipe data
    _nameController = TextEditingController(text: widget.recipe.name);
    _totalTimeController = TextEditingController(text: widget.recipe.totaltime.toString());
    _cuisineController = TextEditingController(text: widget.recipe.cuisine);
    _servingDescriptionController = TextEditingController(text: widget.recipe.servingDescription);
    _servingSizeController = TextEditingController(text: widget.recipe.servingSize);
    _writerController = TextEditingController(text: widget.recipe.writer);

    // Create mutable copies of lists from the immutable RecipeEntity
    _editableIngredients = List.from(widget.recipe.ingredients);
    _editableInstructionSteps = List.from(widget.recipe.instructionSet);
    _editableDescriptionBlocks = List.from(widget.recipe.descriptionBlocks);
    _editableTags = List.from(widget.recipe.tags);

    // Initialize nutrition controllers
    _caloriesController = TextEditingController(text: widget.recipe.nutrition.calories.toStringAsFixed(1));
    _carbsController = TextEditingController(text: widget.recipe.nutrition.carbsG.toStringAsFixed(1));
    _fatController = TextEditingController(text: widget.recipe.nutrition.fatG.toStringAsFixed(1));
    _fiberController = TextEditingController(text: widget.recipe.nutrition.fiberG.toStringAsFixed(1));
    _proteinController = TextEditingController(text: widget.recipe.nutrition.proteinG.toStringAsFixed(1));

    _currentImageUrl = widget.recipe.img;
    _selectedVisibility = widget.recipe.visibility;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalTimeController.dispose();
    _cuisineController.dispose();
    _servingDescriptionController.dispose();
    _servingSizeController.dispose();
    _writerController.dispose();

    _caloriesController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  // --- Image Picker Function ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
        _currentImageUrl = null; // Clear existing URL if new image is picked
      });
    }
  }

  // --- Methods to add/remove dynamic list items ---

  void _addIngredient() {
    setState(() {
      _editableIngredients.add(Ingredient(qty: 0.0, unit: '', name: '', note: ''));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _editableIngredients.removeAt(index);
    });
  }

  void _addInstructionStep() {
    setState(() {
      _editableInstructionSteps.add(InstructionStep(description: ''));
    });
  }

  void _removeInstructionStep(int index) {
    setState(() {
      _editableInstructionSteps.removeAt(index);
    });
  }

  void _addDescriptionBlock() {
    setState(() {
      _editableDescriptionBlocks.add(DescriptionBlock(heading1: '', body: '', image: ''));
    });
  }

  void _removeDescriptionBlock(int index) {
    setState(() {
      _editableDescriptionBlocks.removeAt(index);
    });
  }

  // Method to add a new tag
  void _addTag(String tag) {
    if (tag.isNotEmpty && !_editableTags.contains(tag)) {
      setState(() {
        _editableTags.add(tag);
      });
    }
  }

  // Method to remove a tag
  void _removeTag(String tag) {
    setState(() {
      _editableTags.remove(tag);
    });
  }


  // --- Save Function ---
  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved for FormFields

      // Construct the updated Nutrition object
      final updatedNutrition = Nutrition(
        calories: double.tryParse(_caloriesController.text) ?? 0.0,
        carbsG: double.tryParse(_carbsController.text) ?? 0.0,
        fatG: double.tryParse(_fatController.text) ?? 0.0,
        fiberG: double.tryParse(_fiberController.text) ?? 0.0,
        proteinG: double.tryParse(_proteinController.text) ?? 0.0,
      );

      // Construct the updated RecipeEntity
      RecipeEntity updatedRecipe = widget.recipe.copyWith(
        name: _nameController.text,
        totaltime: int.tryParse(_totalTimeController.text) ?? 0,
        cuisine: _cuisineController.text,
        servingDescription: _servingDescriptionController.text,
        servingSize: _servingSizeController.text,
        writer: _writerController.text,
        ingredients: _editableIngredients,
        instructionSet: _editableInstructionSteps,
        descriptionBlocks: _editableDescriptionBlocks,
        tags: _editableTags,
        nutrition: updatedNutrition,
        visibility: _selectedVisibility,
        // img will be updated separately if a new image is selected
      );

      try {
        final recipeRepository = ref.read(recipeRepositoryProvider);
        // If a new image is selected, upload it using FirebaseUserService
        if (_selectedImageFile != null) {
          // Note: Your FirebaseUserService().uploadUserAvatarToCloudinary
          // must be accessible and return a String URL.
          final newImageUrl = await FirebaseUserService().uploadUserAvatarToCloudinary(_selectedImageFile!);
          updatedRecipe = updatedRecipe.copyWith(img: newImageUrl);

        }

        await recipeRepository.updateRecipe(updatedRecipe);

        // Invalidate the provider so MyRecipesScreen refreshes
        ref.invalidate(myRecipesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe updated successfully!')),
          );
          Navigator.pop(context); // Go back to MyRecipesScreen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update recipe: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Selection ---
              _buildSectionTitle('Recipe Image'),
              Center(
                child: Column(
                  children: [
                    if (_selectedImageFile != null)
                      Image.file(
                        _selectedImageFile!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                    else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                      Image.network(
                        _currentImageUrl!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          width: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Change Image'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Basic Information ---
              _buildSectionTitle('Basic Information'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _totalTimeController,
                decoration: const InputDecoration(labelText: 'Total Time (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cuisineController,
                decoration: const InputDecoration(labelText: 'Cuisine'),
              ),
              TextFormField(
                controller: _writerController,
                decoration: const InputDecoration(labelText: 'Writer'),
              ),
              const SizedBox(height: 20),

              // --- Serving Information ---
              _buildSectionTitle('Serving Information'),
              TextFormField(
                controller: _servingDescriptionController,
                decoration: const InputDecoration(labelText: 'Serving Description (e.g., "Serves 4")'),
              ),
              TextFormField(
                controller: _servingSizeController,
                decoration: const InputDecoration(labelText: 'Serving Size (e.g., "1 cup")'),
              ),
              const SizedBox(height: 20),

              // --- Tags ---
              _buildSectionTitle('Tags'),
              Wrap(
                spacing: 8.0,
                children: _editableTags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                )).toList(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Add Tag'),
                onFieldSubmitted: (value) {
                  _addTag(value);
                  FocusScope.of(context).unfocus(); // Dismiss keyboard
                },
              ),
              const SizedBox(height: 20),

              // --- Ingredients ---
              _buildSectionTitle('Ingredients'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _editableIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _editableIngredients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: ingredient.qty.toString(),
                                  decoration: const InputDecoration(labelText: 'Quantity', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _editableIngredients[index] = ingredient.copyWith(qty: double.tryParse(value) ?? 0.0);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: ingredient.unit,
                                  decoration: const InputDecoration(labelText: 'Unit', isDense: true),
                                  onChanged: (value) {
                                    _editableIngredients[index] = ingredient.copyWith(unit: value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  initialValue: ingredient.name,
                                  decoration: const InputDecoration(labelText: 'Name', isDense: true),
                                  onChanged: (value) {
                                    _editableIngredients[index] = ingredient.copyWith(name: value);
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => _removeIngredient(index),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: ingredient.note,
                            decoration: const InputDecoration(labelText: 'Note (Optional)', isDense: true),
                            onChanged: (value) {
                              _editableIngredients[index] = ingredient.copyWith(note: value.isEmpty ? null : value);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                ),
              ),
              const SizedBox(height: 20),

              // --- Description Blocks ---
              _buildSectionTitle('Description Blocks'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _editableDescriptionBlocks.length,
                itemBuilder: (context, index) {
                  final block = _editableDescriptionBlocks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: block.heading1,
                            decoration: const InputDecoration(labelText: 'Heading'),
                            onChanged: (value) {
                              _editableDescriptionBlocks[index] = block.copyWith(heading1: value);
                            },
                          ),
                          TextFormField(
                            initialValue: block.body,
                            decoration: const InputDecoration(labelText: 'Body'),
                            maxLines: 3,
                            onChanged: (value) {
                              _editableDescriptionBlocks[index] = block.copyWith(body: value);
                            },
                          ),
                          TextFormField(
                            initialValue: block.image,
                            decoration: const InputDecoration(labelText: 'Image URL for Block'),
                            onChanged: (value) {
                              _editableDescriptionBlocks[index] = block.copyWith(image: value);
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeDescriptionBlock(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _addDescriptionBlock,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Description Block'),
                ),
              ),
              const SizedBox(height: 20),

              // --- Instruction Steps ---
              _buildSectionTitle('Instruction Steps'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _editableInstructionSteps.length,
                itemBuilder: (context, index) {
                  final step = _editableInstructionSteps[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: step.description,
                              decoration: InputDecoration(labelText: 'Step ${index + 1}'),
                              maxLines: null, // Allow multiple lines
                              onChanged: (value) {
                                _editableInstructionSteps[index] = step.copyWith(description: value);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _removeInstructionStep(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _addInstructionStep,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                ),
              ),
              const SizedBox(height: 20),

              // --- Nutrition Information ---
              _buildSectionTitle('Nutrition Information'),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(labelText: 'Carbohydrates (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fiberController,
                decoration: const InputDecoration(labelText: 'Fiber (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // --- Visibility Selector ---
              _buildSectionTitle('Visibility'),
              DropdownButtonFormField<String>(
                value: _selectedVisibility,
                decoration: const InputDecoration(labelText: 'Recipe Visibility'),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                  DropdownMenuItem(value: 'unlisted', child: Text('Unlisted')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedVisibility = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // --- Save Button ---
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveRecipe,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// --- Extend your model classes with copyWith for easier updates ---

// Example for Ingredient (you need to do this for all sub-models)
extension IngredientExtension on Ingredient {
  Ingredient copyWith({
    double? qty,
    String? unit,
    String? name,
    String? note,
  }) {
    return Ingredient(
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      name: name ?? this.name,
      note: note ?? this.note,
    );
  }
}

extension DescriptionBlockExtension on DescriptionBlock {
  DescriptionBlock copyWith({
    String? heading1,
    String? body,
    String? image,
  }) {
    return DescriptionBlock(
      heading1: heading1 ?? this.heading1,
      body: body ?? this.body,
      image: image ?? this.image,
    );
  }
}

extension InstructionStepExtension on InstructionStep {
  InstructionStep copyWith({
    String? description,
  }) {
    return InstructionStep(
      description: description ?? this.description,
    );
  }
}

extension NutritionExtension on Nutrition {
  Nutrition copyWith({
    double? calories,
    double? carbsG,
    double? fatG,
    double? fiberG,
    double? proteinG,
  }) {
    return Nutrition(
      calories: calories ?? this.calories,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      fiberG: fiberG ?? this.fiberG,
      proteinG: proteinG ?? this.proteinG,
    );
  }
}