import 'package:flutter/material.dart';

import '../../domain/recipe_entity.dart';
import 'package:flutter/cupertino.dart';

class RecipeScreen extends StatelessWidget {
  final RecipeEntity recipe;

  const RecipeScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: Image.network(recipe.img),
    );
  }
}

