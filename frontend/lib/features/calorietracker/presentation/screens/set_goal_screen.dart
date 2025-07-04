import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/calorietracker/data/calorie_tracker_repository.dart';
import '/features/calorietracker/domain/calorie_entry.dart';

class SetGoalScreen extends StatefulWidget {
  final Goal? goalToEdit;

  const SetGoalScreen({Key? key, this.goalToEdit}) : super(key: key);

  @override
  State<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  final CalorieTrackerRepository _repository = CalorieTrackerRepository();
  final TextEditingController _caloriesController = TextEditingController();

  GoalType _selectedGoalType = GoalType.daily;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateEndDate();
    if (widget.goalToEdit != null) {
      _selectedGoalType = widget.goalToEdit!.type;
      _caloriesController.text = widget.goalToEdit!.targetCalories.toString();
      _startDate = widget.goalToEdit!.startDate;
      _endDate = widget.goalToEdit!.endDate;
    }
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  void _updateEndDate() {
    switch (_selectedGoalType) {
      case GoalType.daily:
        _endDate = DateTime(_startDate.year, _startDate.month, _startDate.day, 23, 59, 59);
        break;
      case GoalType.weekly:
        _endDate = _startDate.add(const Duration(days: 6));
        _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
        break;
      case GoalType.monthly:
        int lastDay = DateTime(_startDate.year, _startDate.month + 1, 0).day;
        _endDate = DateTime(_startDate.year, _startDate.month, lastDay, 23, 59, 59);
        break;
    }
    setState(() {});
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _updateEndDate();
      });
    }
  }

  void _saveGoal() async {
    if (_caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a calorie target')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final goal = Goal(
        id: widget.goalToEdit?.id ?? '',
        userId: user.uid,
        targetCalories: double.parse(_caloriesController.text),
        startDate: _startDate,
        endDate: _endDate,
        type: _selectedGoalType,
      );

      if (widget.goalToEdit != null) {
        await _repository.updateGoal(goal);
      } else {
        await _repository.setGoal(goal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.goalToEdit != null
              ? 'Goal updated successfully!'
              : 'Goal saved successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving goal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getGoalDescription() {
    final caloriesText = _caloriesController.text.isEmpty ? "___" : _caloriesController.text;

    String periodDescription;
    switch (_selectedGoalType) {
      case GoalType.daily:
        periodDescription = "for ${DateFormat('MMMM d, yyyy').format(_startDate)}";
        break;
      case GoalType.weekly:
        periodDescription = "for the week of ${DateFormat('MMM d').format(_startDate)} to ${DateFormat('MMM d, yyyy').format(_endDate)}";
        break;
      case GoalType.monthly:
        periodDescription = "for ${DateFormat('MMMM yyyy').format(_startDate)}";
        break;
    }

    return "You'll receive a reminder about your goal of $caloriesText calories $periodDescription.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Calorie Goal'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView(
                  children: [
                    Text(
                      widget.goalToEdit != null ? 'Edit Your Goal' : 'Set a New Goal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Target calories input
                    TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target Calories',
                        hintText: 'e.g. 2000',
                        prefixIcon: const Icon(Icons.local_fire_department),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Goal type selector
                    Text('Goal Period', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SegmentedButton<GoalType>(
                      segments: const [
                        ButtonSegment(value: GoalType.daily, label: Text("Daily"), icon: Icon(Icons.calendar_today)),
                        ButtonSegment(value: GoalType.weekly, label: Text("Weekly"), icon: Icon(Icons.view_week)),
                        ButtonSegment(value: GoalType.monthly, label: Text("Monthly"), icon: Icon(Icons.calendar_month)),
                      ],
                      selected: {_selectedGoalType},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _selectedGoalType = selection.first;
                          _updateEndDate();
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Start date
                    Text('Start Date', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectStartDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('MMM d, yyyy').format(_startDate)),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // End date
                    Text('End Date', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM d, yyyy').format(_endDate)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Goal summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getGoalDescription(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check),
                        label: Text(widget.goalToEdit != null ? 'UPDATE GOAL' : 'SET GOAL'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveGoal,
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
