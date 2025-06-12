// lib/features/calorietracker/presentation/screens/goal_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/features/calorietracker/data/calorie_tracker_repository.dart';
import '/features/calorietracker/domain/calorie_entry.dart';
import '../widgets/goal_tab.dart';
import 'add_calorie_entry.dart';
import 'set_goal_screen.dart' as goal_screen;

class GoalScreen extends StatefulWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> with SingleTickerProviderStateMixin {
  final CalorieTrackerRepository _repository = CalorieTrackerRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  String _getStartDateForPeriod(GoalType type) {
    final now = DateTime.now();
    switch (type) {
      case GoalType.daily:
        return DateFormat('MMM d').format(now);
      case GoalType.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateFormat('MMM d').format(startOfWeek);
      case GoalType.monthly:
        return DateFormat('MMM').format(now);
    }
  }

  String _getEndDateForPeriod(GoalType type) {
    final now = DateTime.now();
    switch (type) {
      case GoalType.daily:
        return DateFormat('MMM d').format(now);
      case GoalType.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return DateFormat('MMM d').format(endOfWeek);
      case GoalType.monthly:
        final lastDay = DateTime(now.year, now.month + 1, 0);
        return DateFormat('MMM d').format(lastDay);
    }
  }

  Stream<List<CalorieEntry>> _getEntriesForPeriod(GoalType type) {
    final now = DateTime.now();
    switch (type) {
      case GoalType.daily:
        return _repository.getEntriesForDay(now);
      case GoalType.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return _repository.getEntriesForMonth(startOfWeek.year, startOfWeek.month);
      case GoalType.monthly:
        return _repository.getEntriesForMonth(now.year, now.month);
    }
  }

  String _getPeriodTitle(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return 'Today';
      case GoalType.weekly:
        return 'This Week';
      case GoalType.monthly:
        return 'This Month';
    }
  }

  void _editEntry(CalorieEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCalorieEntryScreen(entryToEdit: entry)),
    );
  }

  Future<void> _deleteEntry(CalorieEntry entry) async {
    try {
      await _repository.deleteEntry(entry.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: $e')),
      );
    }
  }

  void _editGoal(Goal goal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => goal_screen.SetGoalScreen(goalToEdit: goal),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete this ${goal.type.name} goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Add delete method to repository if it doesn't exist
        await _repository.deleteGoal(goal.id);

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goal deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting goal: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Goals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Set New Goal',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const goal_screen.SetGoalScreen(),
                ),
              );
              setState(() {}); // Refresh after setting goal
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GoalTab(
            type: GoalType.daily,
            entriesStream: _getEntriesForPeriod(GoalType.daily),
            goalsStream: _repository.getCurrentGoals(),
            onEditEntry: _editEntry,
            onDeleteEntry: _deleteEntry,
            onEditGoal: _editGoal,
            onDeleteGoal: _deleteGoal,
            periodTitle: _getPeriodTitle(GoalType.daily),
            dateRange: '${_getStartDateForPeriod(GoalType.daily)} - ${_getEndDateForPeriod(GoalType.daily)}',
          ),
          GoalTab(
            type: GoalType.weekly,
            entriesStream: _getEntriesForPeriod(GoalType.weekly),
            goalsStream: _repository.getCurrentGoals(),
            onEditEntry: _editEntry,
            onDeleteEntry: _deleteEntry,
            onEditGoal: _editGoal,
            onDeleteGoal: _deleteGoal,
            periodTitle: _getPeriodTitle(GoalType.weekly),
            dateRange: '${_getStartDateForPeriod(GoalType.weekly)} - ${_getEndDateForPeriod(GoalType.weekly)}',
          ),
          GoalTab(
            type: GoalType.monthly,
            entriesStream: _getEntriesForPeriod(GoalType.monthly),
            goalsStream: _repository.getCurrentGoals(),
            onEditEntry: _editEntry,
            onDeleteEntry: _deleteEntry,
            onEditGoal: _editGoal,
            onDeleteGoal: _deleteGoal,
            periodTitle: _getPeriodTitle(GoalType.monthly),
            dateRange: '${_getStartDateForPeriod(GoalType.monthly)} - ${_getEndDateForPeriod(GoalType.monthly)}',
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCalorieEntryScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Meal'),
      )
          : null,
    );
  }
}