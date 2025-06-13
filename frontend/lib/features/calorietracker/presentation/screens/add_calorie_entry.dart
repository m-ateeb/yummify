import 'package:flutter/material.dart';
import '/features/calorietracker/data/calorie_tracker_repository.dart';
import '/features/calorietracker/domain/calorie_entry.dart';
import 'search_food_screen.dart';

class AddCalorieEntryScreen extends StatefulWidget {
  final CalorieEntry? entryToEdit;
  const AddCalorieEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  _AddCalorieEntryScreenState createState() => _AddCalorieEntryScreenState();
}

class _AddCalorieEntryScreenState extends State<AddCalorieEntryScreen> {
  final CalorieTrackerRepository _repository = CalorieTrackerRepository();
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();
  final TextEditingController _servingDescriptionController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      _mealController.text = widget.entryToEdit!.mealName;
      _caloriesController.text = widget.entryToEdit!.calories.toString();
      _selectedDate = widget.entryToEdit!.timestamp;
      _proteinController.text = widget.entryToEdit!.protein.toString();
      _fatController.text = widget.entryToEdit!.fat.toString();
      _carbsController.text = widget.entryToEdit!.carbs.toString();
      _fiberController.text = widget.entryToEdit!.fiber.toString();
      // _servingDescriptionController.text = widget.entryToEdit!.servingDescription;
      // _servingSizeController.text = widget.entryToEdit!.servingSize ?? '';
    }
  }

  void _saveEntry() async {
    if (_mealController.text.isEmpty || _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter meal and calories')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final entry = CalorieEntry(
        id: widget.entryToEdit?.id ?? '',
        mealName: _mealController.text,
        calories: double.parse(_caloriesController.text),
        timestamp: _selectedDate,
        protein: double.tryParse(_proteinController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        fiber: double.tryParse(_fiberController.text) ?? 0,
        // servingDescription: _servingDescriptionController.text,
        // servingSize: _servingSizeController.text,
      );

      if (widget.entryToEdit != null) {
        await _repository.updateEntry(entry.id, entry);
      } else {
        await _repository.addEntry(entry);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _searchFood() async {
    final selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchFoodScreen()),
    );

    if (selectedFood != null && mounted) {
      setState(() {
        _mealController.text = selectedFood['label'];
        if (selectedFood['calories'] != null) {
          _caloriesController.text = selectedFood['calories'].toString();
        }
        if (selectedFood['protein'] != null) {
          _proteinController.text = selectedFood['protein'].toString();
        }
        if (selectedFood['fat'] != null) {
          _fatController.text = selectedFood['fat'].toString();
        }
        if (selectedFood['carbs'] != null) {
          _carbsController.text = selectedFood['carbs'].toString();
        }
        if (selectedFood['fiber'] != null) {
          _fiberController.text = selectedFood['fiber'].toString();
        }

        // Improved logic for serving description
        final servingDescriptionKeys = ['servingdescription', 'serving_description', 'description'];
        String? foundServingDescription;
        for (final key in servingDescriptionKeys) {
          if (selectedFood[key] != null && selectedFood[key].toString().isNotEmpty) {
            foundServingDescription = selectedFood[key].toString();
            break;
          }
        }
        _servingDescriptionController.text = foundServingDescription ?? '';

        // Improved logic for serving size
        final servingSizeKeys = ['servingsize', 'serving_size', 'size'];
        String? foundServingSize;
        for (final key in servingSizeKeys) {
          if (selectedFood[key] != null && selectedFood[key].toString().isNotEmpty) {
            foundServingSize = selectedFood[key].toString();
            break;
          }
        }
        _servingSizeController.text = foundServingSize ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryToEdit != null ? 'Edit Calorie Entry' : 'Add Calorie Entry'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: SingleChildScrollView( // Added SingleChildScrollView to fix overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search Food Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Search Food'),
                      onPressed: _searchFood,
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _mealController,
                      decoration: InputDecoration(
                        labelText: 'Meal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 13),

                    TextField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.local_fire_department),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 13),

                    TextField(
                      controller: _proteinController,
                      decoration: InputDecoration(
                        labelText: 'Protein (g)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.egg),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 13),

                    TextField(
                      controller: _fatController,
                      decoration: InputDecoration(
                        labelText: 'Fat (g)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.oil_barrel),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 13),

                    TextField(
                      controller: _carbsController,
                      decoration: InputDecoration(
                        labelText: 'Carbs (g)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.bakery_dining),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 13),

                    TextField(
                      controller: _fiberController,
                      decoration: InputDecoration(
                        labelText: 'Fiber (g)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.grass),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 13),

                    TextField(
                      controller: _servingDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Serving Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 13),

                    TextField(
                      controller: _servingSizeController,
                      decoration: InputDecoration(
                        labelText: 'Serving Size',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.format_size),
                      ),
                    ),
                    const SizedBox(height: 13),

                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveEntry,
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(
                        widget.entryToEdit != null ? 'UPDATE ENTRY' : 'SAVE ENTRY',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
