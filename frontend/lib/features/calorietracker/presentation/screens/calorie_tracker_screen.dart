import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/features/calorietracker/data/calorie_tracker_repository.dart';
import '/features/calorietracker/domain/calorie_entry.dart';
import '/features/calorietracker/presentation/widgets/calorie_entry_card.dart';
import '/features/calorietracker/presentation/widgets/calorie_summary_card.dart';
import '/features/calorietracker/presentation/widgets/goal_progress_card.dart';
import 'add_calorie_entry.dart';
import 'set_goal_screen.dart';
import 'goal_screen.dart';
import '/shared/widgets/banner_ad.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final CalorieTrackerRepository _repository = CalorieTrackerRepository();
  DateTime _selectedDate = DateTime.now();
  String _filterPeriod = 'day'; // 'day', 'month', 'year'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Stream<List<CalorieEntry>> _getFilteredEntries() {
    switch (_filterPeriod) {
      case 'month':
        return _repository.getEntriesForMonth(_selectedDate.year, _selectedDate.month);
      case 'year':
        return _repository.getEntriesForYear(_selectedDate.year);
      default:
        return _repository.getEntriesForDay(_selectedDate);
    }
  }

  void _navigateToSetGoal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetGoalScreen()),
    );
    setState(() {});
  }

  String _formatPeriodDate() {
    switch (_filterPeriod) {
      case 'month':
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case 'year':
        return DateFormat('yyyy').format(_selectedDate);
      default:
        return DateFormat('MMMM d, yyyy').format(_selectedDate);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60.0,
            pinned: true,
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Calorie Tracker'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filter section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Filter By"),
                          trailing: Icon(_isFilterExpanded ? Icons.expand_less : Icons.expand_more),
                          onTap: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                        ),
                        if (_isFilterExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                ToggleButtons(
                                  isSelected: [
                                    _filterPeriod == 'day',
                                    _filterPeriod == 'month',
                                    _filterPeriod == 'year',
                                  ],
                                  onPressed: (int index) {
                                    setState(() {
                                      _filterPeriod = ['day', 'month', 'year'][index];
                                    });
                                  },
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('Day'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('Month'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('Year'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatPeriodDate()),
                                        const Icon(Icons.calendar_today),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    labelText: 'Search Meals',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary + Goal Cards
                  StreamBuilder<List<CalorieEntry>>(
                    stream: _getFilteredEntries(),
                    builder: (context, snapshot) {
                      final entries = snapshot.data ?? [];
                      final totalCalories = entries.fold<int>(0, (sum, e) => sum + e.calories.toInt());

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CalorieSummaryCard(entries: entries),
                          const SizedBox(height: 12),
                          StreamBuilder<List<Goal>>(
                            stream: _repository.getCurrentGoals(),
                            builder: (context, goalSnap) {
                              if (!goalSnap.hasData || goalSnap.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const GoalScreen()),
                                  );
                                },
                                child: GoalProgressCard(
                                  goal: goalSnap.data!.first,
                                  consumedCalories: totalCalories,
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SetGoalScreen()),
                                    );
                                  },
                                  onDelete: () {
                                    // Implement delete logic or callback here
                                  },
                                ),
                              );
                            },
                          ),
                          MyBannerAdWidget(), // Banner at bottom

                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Entry List
          StreamBuilder<List<CalorieEntry>>(
            stream: _getFilteredEntries(),
            builder: (context, snapshot) {
              final allEntries = snapshot.data ?? [];
              final entries = _searchQuery.isEmpty
                  ? allEntries
                  : allEntries.where((e) => e.mealName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              if (entries.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('No entries found.')));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: CalorieEntryCard(
                      entry: entries[index],
                      onEdit: _editEntry,
                      onDelete: _deleteEntry,
                    ),
                  ),
                  childCount: entries.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCalorieEntryScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Meal'),
      ),
    );
  }
}
