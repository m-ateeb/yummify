import 'package:flutter/material.dart';
import 'package:frontend/core/services/firebase_meal_service.dart';

class SearchFoodScreen extends StatefulWidget {
  const SearchFoodScreen({super.key});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  final FirebaseMealService service = FirebaseMealService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  List<String> _recentSearches = [];
  List<String> _allSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final suggestions = await service.fetchAllMealNames();
    setState(() => _allSuggestions = suggestions);
  }

  void _saveSearch(String query) {
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches = _recentSearches.sublist(0, 5);
        }
      });
    }
  }

  void _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _results = [];
    });

    try {
      final foods = await service.searchFoods(query);
      _saveSearch(query);
      setState(() {
        _results = foods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    }
  }

  void _selectFood(Map<String, dynamic> item) async {
    setState(() => _isLoading = true);
    try {
      final nutrition = await service.fetchNutrition(item['id']);
      // Use the new fetchNutrition result for serving size and description
      final servingSize = nutrition['serving_size'];
      final servingDescription = nutrition['serving_description'];

      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(item['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nutrition['image'] != null)
                Center(child: Image.network(nutrition['image'])),
              _nutritionRow('Calories', nutrition['calories'], suffix: 'kcal'),
              _nutritionRow('Protein', nutrition['protein'], suffix: 'g'),
              _nutritionRow('Fat', nutrition['fat'], suffix: 'g'),
              _nutritionRow('Carbohydrates', nutrition['carbs'], suffix: 'g'),
              _nutritionRow('Fiber', nutrition['fiber'], suffix: 'g'),
              _nutritionRow('Serving', servingDescription),
              _nutritionRow('Serving Size', servingSize),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, {
                  'label': item['name'],
                  'calories': nutrition['calories'],
                  'protein': nutrition['protein'],
                  'fat': nutrition['fat'],
                  'carbs': nutrition['carbs'],
                  'fiber': nutrition['fiber'],
                  'servingdescription': servingDescription,
                  'servingsize': servingSize,
                  'image': nutrition['image'],
                });
              },
              child: const Text('Add to Tracker'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nutrition error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _allSuggestions.where((option) =>
                    option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _searchController.text = selection;
                _searchFood();
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                _searchController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                    labelText: 'Enter a meal (e.g., butter)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchFood,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            if (_recentSearches.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Searches:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 8,
                children: _recentSearches.map((q) {
                  return ActionChip(
                    label: Text(q),
                    onPressed: () {
                      _searchController.text = q;
                      _searchFood();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text('No meals found.'))
                    : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, index) {
                    final item = _results[index];
                    return ListTile(
                      leading: const Icon(Icons.fastfood),
                      title: Text(item['name']),
                      onTap: () => _selectFood(item),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _nutritionRow(String label, dynamic value, {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(value != null && value.toString().isNotEmpty ? '$value$suffix' : '--'),
        ],
      ),
    );
  }
}
