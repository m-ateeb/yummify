import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/features/user/data/firebase_user_service.dart';
import 'package:frontend/features/recipe/domain/recipe_entity.dart';
import 'package:frontend/providers/providers.dart';
import 'package:frontend/features/recipe/data/recipe_repository_provider.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _totalTimeController = TextEditingController();

  String? _selectedCuisine;
  String? _selectedStatus = 'public';

  File? _pickedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  final List<DescriptionBlock> _descriptionBlocks = [];
  final List<Ingredient> _ingredients = [];
  final List<InstructionStep> _instructions = [];

  final List<String> _cuisineOptions = [
    'Italian',
    'Mexican',
    'Indian',
    'Chinese',
    'Japanese',
    'Thai',
    'French',
    'American',
    'Mediterranean',
    'Other'
  ];

  @override
  void dispose() {
    _recipeNameController.dispose();
    _totalTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void _addDescriptionBlock() {
    final headingController = TextEditingController();
    final bodyController = TextEditingController();
    File? pickedDescImage;
    bool isUploadingDescImage = false;

    Future<void> pickDescImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        setState(() {
          pickedDescImage = File(picked.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text("Add Description Block", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: headingController,
                      decoration: _dialogInputDecoration("Heading"),
                      validator: (value) => value!.isEmpty ? 'Heading is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: bodyController,
                      decoration: _dialogInputDecoration("Body"),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Body is required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        pickedDescImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  pickedDescImage!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, size: 30, color: Colors.grey),
                              ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: isUploadingDescImage ? null : () async {
                            await pickDescImage();
                            setStateDialog(() {});
                          },
                          icon: const Icon(Icons.upload),
                          label: Text(isUploadingDescImage ? "Uploading..." : "Pick Image"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (headingController.text.isEmpty || bodyController.text.isEmpty || pickedDescImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields and pick an image for the description block.")),
                      );
                      return;
                    }
                    setStateDialog(() {
                      isUploadingDescImage = true;
                    });
                    try {
                      final uploadedUrl = await FirebaseUserService().uploadUserAvatarToCloudinary(pickedDescImage!);
                      setState(() {
                        _descriptionBlocks.add(DescriptionBlock(
                          heading1: headingController.text,
                          body: bodyController.text,
                          image: uploadedUrl,
                        ));
                      });
                      Navigator.of(ctx).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to upload image: ${e.toString()}")),
                      );
                    } finally {
                      setStateDialog(() {
                        isUploadingDescImage = false;
                      });
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addIngredient() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final unitController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Add Ingredient", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: _dialogInputDecoration("Name")),
            const SizedBox(height: 12),
            TextField(controller: qtyController, decoration: _dialogInputDecoration("Quantity"), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: unitController, decoration: _dialogInputDecoration("Unit")),
            const SizedBox(height: 12),
            TextField(controller: noteController, decoration: _dialogInputDecoration("Note (Optional)")),
          ],
        ),
        actions: [
          TextButton(child: const Text("Cancel", style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () {
              final double? parsedQty = double.tryParse(qtyController.text);
              if (nameController.text.isNotEmpty && parsedQty != null && unitController.text.isNotEmpty) {
                setState(() {
                  _ingredients.add(Ingredient(
                    name: nameController.text,
                    qty: parsedQty,
                    unit: unitController.text,
                    note: noteController.text.isEmpty ? null : noteController.text,
                  ));
                });
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ingredient name, quantity (must be a number), and unit are required.")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addInstruction() {
    final instructionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Add Instruction Step", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        content: TextFormField(
          controller: instructionController,
          decoration: _dialogInputDecoration("Step Description"),
          maxLines: 3,
          validator: (value) => value!.isEmpty ? 'Description is required' : null,
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () {
              if (instructionController.text.isNotEmpty) {
                setState(() {
                  _instructions.add(InstructionStep(description: instructionController.text));
                });
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Instruction description cannot be empty.")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
        color: Colors.black,
      ),
    ),
  );

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_descriptionBlocks.isEmpty || _ingredients.isEmpty || _instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one description block, ingredient, and instruction.")),
      );
      return;
    }
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a recipe image.")),
      );
      return;
    }
    final userProfileAsync = ref.read(userProfileProvider);
    if (userProfileAsync.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Row(children: [CircularProgressIndicator(color: Colors.white), SizedBox(width: 10), Text("Loading user data...")])),
      );
      await Future.delayed(Duration.zero);
      return;
    }
    if (userProfileAsync.hasError || userProfileAsync.value == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to create a recipe. Please log in.")),
      );
      return;
    }
    final currentUserProfile = userProfileAsync.value!;
    final userId = currentUserProfile.uid;
    final userRole = currentUserProfile.role;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Row(children: [CircularProgressIndicator(color: Colors.white), SizedBox(width: 10), Text("Saving recipe...")])),
    );

    try {
      setState(() {
        _isUploadingImage = true;
      });
      final uploadedUrl = await FirebaseUserService().uploadUserAvatarToCloudinary(_pickedImage!);
      setState(() {
        _uploadedImageUrl = uploadedUrl;
        _isUploadingImage = false;
      });

      final intTotalTime = int.tryParse(_totalTimeController.text) ?? 0;

      final newRecipe = RecipeEntity(
        id: '',
        name: _recipeNameController.text.trim(),
        writer: userId,
        createdBy: userId,
        role: userRole,
        visibility: _selectedStatus!,
        img: _uploadedImageUrl!,
        tags: [],
        servingDescription: 'Serves 1',
        servingSize: '1',
        searchIndex: [],
        nutrition: Nutrition(calories: 0, carbsG: 0, fatG: 0, fiberG: 0, proteinG: 0),
        apiCalls: [],
        review: 0.0,
        updatedAt: DateTime.now(),
        descriptionBlocks: _descriptionBlocks,
        ingredients: _ingredients,
        instructionSet: _instructions,
        totaltime: intTotalTime,
        cuisine: _selectedCuisine ?? 'Other',
        createdAt: DateTime.now(),
        status: _selectedStatus!,
        averageRating: 0.0,
        ratingCount: 0,
        totalRatingSum: 0.0,
      );

      final repo = ref.read(recipeRepositoryProvider);
      await repo.createRecipe(newRecipe);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe saved successfully!"), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      setState(() {
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      debugPrint('Error saving recipe: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save recipe: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create a Recipe",
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Recipe Details"),
              TextFormField(
                controller: _recipeNameController,
                decoration: _inputDecoration("Recipe Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _pickedImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isUploadingImage ? null : _pickImage,
                    icon: const Icon(Icons.upload),
                    label: Text(_isUploadingImage ? "Uploading..." : "Pick Image"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalTimeController,
                decoration: _inputDecoration("Total Time (minutes)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total time';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCuisine,
                decoration: _inputDecoration("Cuisine Type"),
                items: _cuisineOptions.map((cuisine) {
                  return DropdownMenuItem(
                    value: cuisine,
                    child: Text(cuisine),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCuisine = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a cuisine type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: _inputDecoration("Recipe Status"),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              _sectionTitle("Description Blocks"),
              ..._descriptionBlocks.map((block) {
                return _buildDescriptionBlockCard(block);
              }).toList(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FloatingActionButton.small(
                    heroTag: 'add_desc_block',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    onPressed: _addDescriptionBlock,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              _sectionTitle("Ingredients"),
              _buildIngredientsList(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FloatingActionButton.small(
                    heroTag: 'add_ingredient',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    onPressed: _addIngredient,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              _sectionTitle("Instructions"),
              _buildInstructionsList(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FloatingActionButton.small(
                    heroTag: 'add_instruction',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    onPressed: _addInstruction,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveRecipe,
                child: const Text(
                  "Save Recipe",
                  style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      fillColor: Colors.grey[50],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      fillColor: Colors.grey[50],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildDescriptionBlockCard(DescriptionBlock block) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              block.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  height: 180,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.heading1,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  block.body,
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  _descriptionBlocks.remove(block);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    if (_ingredients.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        child: const Text(
          "No ingredients added yet. Click '+' to add.",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _ingredients.length,
        itemBuilder: (context, index) {
          final ing = _ingredients[index];
          return Dismissible(
            key: ValueKey(ing),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                _ingredients.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${ing.name} removed")),
              );
            },
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            child: ListTile(
              leading: Icon(Icons.circle, size: 8, color: Colors.grey[600]),
              title: Text(
                "${ing.qty} ${ing.unit} ${ing.name}${ing.note != null && ing.note!.isNotEmpty ? ' (${ing.note})' : ''}",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionsList() {
    if (_instructions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        child: const Text(
          "No instructions added yet. Click '+' to add.",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _instructions.length,
        itemBuilder: (context, index) {
          final step = _instructions[index];
          return Dismissible(
            key: ValueKey(step),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                _instructions.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Instruction ${index + 1} removed")),
              );
            },
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 12,
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                step.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          );
        },
      ),
    );
  }
}