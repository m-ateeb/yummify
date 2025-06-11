import 'package:flutter/material.dart';
import '/core/services/edamam_service.dart';

class SearchFoodScreen extends StatefulWidget {
  const SearchFoodScreen({super.key});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  final EdamamService _edamamService = EdamamService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;

  void _analyzeNutrition() async {
    final ingredient = _searchController.text.trim();
    if (ingredient.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nutrition = await _edamamService.analyzeNutrition(ingredient);

      setState(() {
        _isLoading = false;
      });

      final calories = (nutrition['calories'] is int)
          ? nutrition['calories']
          : (nutrition['calories'] is double
              ? (nutrition['calories'] as double).toInt()
              : int.tryParse(nutrition['calories']?.toString() ?? '0') ?? 0);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(ingredient),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calories: $calories kcal'),
              const SizedBox(height: 10),
              // Optionally show some main nutrients, for example:
              if (nutrition['totalNutrients'] != null)
                ..._buildNutrientWidgets(nutrition['totalNutrients']),
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
                  'label': ingredient,
                  'calories': calories,
                }); // Pass data back if needed
              },
              child: const Text('Add to Tracker'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching nutrition: $e')),
      );
    }
  }

  List<Widget> _buildNutrientWidgets(Map<String, dynamic> totalNutrients) {
    // Display some common nutrients, e.g. Protein, Fat, Carbs
    final nutrientsToShow = ['PROCNT', 'FAT', 'CHOCDF']; // Protein, Fat, Carbs
    List<Widget> widgets = [];

    for (var key in nutrientsToShow) {
      if (totalNutrients.containsKey(key)) {
        final nutrient = totalNutrients[key];
        final label = nutrient['label'] ?? key;
        final quantity = nutrient['quantity'] is num
            ? (nutrient['quantity'] as num).toStringAsFixed(1)
            : nutrient['quantity']?.toString() ?? '0';
        final unit = nutrient['unit'] ?? '';

        widgets.add(Text('$label: $quantity $unit'));
      }
    }

    return widgets;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutritional Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _analyzeNutrition(),
              decoration: InputDecoration(
                labelText: 'Enter full ingredient (e.g., "1 apple")',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _analyzeNutrition,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
