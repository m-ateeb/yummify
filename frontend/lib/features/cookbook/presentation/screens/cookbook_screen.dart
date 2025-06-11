import 'package:flutter/material.dart';
import '/features/cookbook/data/cookbook_repository.dart';
import '/features/cookbook/domain/cookbook_entity.dart';
import '/features/cookbook/presentation/widgets/recipe_tile.dart';
import 'add_recipe_screen.dart';
import 'package:frontend/core/services/edamam_recipe_service.dart';

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> {
  final CookbookRepository _repository = CookbookRepository();
  final EdamamRecipeService _edamamService = EdamamRecipeService();
  final ScrollController _scrollController = ScrollController();

  List<CookbookEntity> _recipes = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitialRecipes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _loadMoreRecipes();
      }
    });
  }

  Future<void> _loadInitialRecipes() async {
    setState(() => _isLoading = true);
    try {
      _repository.resetPagination();
      _edamamService.reset();
      final firebase = await _repository.fetchUserRecipes();
      final edamam = await _edamamService.fetchRecipes(
        query: 'chicken',
        from: 0,
        to: 20,
        diet: ['low-carb'],
        health: ['gluten-free'],
        cuisineType: ['Italian'],
        mealType: ['Dinner'],
      );

      setState(() {
        _recipes = [...firebase, ...edamam];
        _hasMore = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreRecipes() async {
    setState(() => _isLoading = true);
    try {
      final firebase = await _repository.fetchUserRecipes();
      final edamam = await _edamamService.fetchRecipes( query: 'chicken',
        from: 0,
        to: 20,
        diet: ['low-carb'],
        health: ['gluten-free'],
        cuisineType: ['Italian'],
        mealType: ['Dinner'],
      );

      if (firebase.isEmpty && edamam.isEmpty) {
        _hasMore = false;
      }

      setState(() {
        _recipes.addAll([...firebase, ...edamam]);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddRecipeScreen()),
              ).then((_) => _loadInitialRecipes());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialRecipes,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _recipes.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _recipes.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return RecipeTile(recipe: _recipes[index]);
          },
        ),
      ),
    );
  }
}
