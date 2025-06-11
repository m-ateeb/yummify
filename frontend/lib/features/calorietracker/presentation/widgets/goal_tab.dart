// lib/features/calorietracker/presentation/widgets/goal_tab.dart
import 'package:flutter/material.dart';
import '/features/calorietracker/data/calorie_tracker_repository.dart';
import '/features/calorietracker/domain/calorie_entry.dart';
import 'goal_progress_card.dart'; // New widget we'll create
import 'period_summary_card.dart';
import 'empty_goal_state.dart';
import 'calorie_entry_card.dart';

class GoalTab extends StatelessWidget {
  final GoalType type;
  final Stream<List<CalorieEntry>> entriesStream;
  final Stream<List<Goal>> goalsStream;
  final Function(CalorieEntry) onEditEntry;
  final Function(CalorieEntry) onDeleteEntry;
  final Function(Goal) onEditGoal;
  final Function(Goal) onDeleteGoal;
  final String periodTitle;
  final String dateRange;

  const GoalTab({
    Key? key,
    required this.type,
    required this.entriesStream,
    required this.goalsStream,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.onEditGoal,
    required this.onDeleteGoal,
    required this.periodTitle,
    required this.dateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Goal>>(
      stream: goalsStream,
      builder: (context, goalSnapshot) {
        if (goalSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter goals by type
        final goals = goalSnapshot.data
            ?.where((g) => g.type == type)
            .toList() ?? [];

        return StreamBuilder<List<CalorieEntry>>(
          stream: entriesStream,
          builder: (context, entriesSnapshot) {
            if (entriesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = entriesSnapshot.data ?? [];
            final consumedCalories = entries.fold<int>(
                0, (sum, entry) => sum + entry.calories);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Summary Card
                  PeriodSummaryCard(
                    title: periodTitle,
                    dateRange: dateRange,
                    consumedCalories: consumedCalories,
                  ),

                  const SizedBox(height: 16),

                  // Show active goals for this type
                  if (goals.isNotEmpty)
                    ...goals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GoalProgressCard(
                        goal: goal,
                        consumedCalories: consumedCalories,
                        onEdit: () => onEditGoal(goal),
                        onDelete: () => onDeleteGoal(goal),
                      ),
                    )).toList()
                  else
                    EmptyGoalView(goalType: type.name),

                  // Daily entries if showing daily goal
                  if (type == GoalType.daily && entries.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Today\'s Meals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CalorieEntryCard(
                        entry: entry,
                        onEdit: onEditEntry,
                        onDelete: onDeleteEntry,
                      ),
                    )).toList(),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}