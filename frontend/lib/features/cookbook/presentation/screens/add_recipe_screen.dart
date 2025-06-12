import 'package:flutter/material.dart';
import '/features/cookbook/data/cookbook_repository.dart';
import '/features/cookbook/domain/cookbook_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final CookbookRepository _repository = CookbookRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;

  void _saveRecipe() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle not signed in
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be signed in to add a recipe.')),
      );
      return;
    }
      if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newRecipe = CookbookEntity(
      id: '', // Firestore will generate the ID
      title: _titleController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      authorId: user.uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.addRecipe(newRecipe);

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveRecipe,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
