import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '/features/calorietracker/domain/calorie_entry.dart';

class GoalProgressCard extends StatelessWidget {
  final Goal goal;
  final int consumedCalories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalProgressCard({
    Key? key,
    required this.goal,
    required this.consumedCalories,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _getGoalPeriodText(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return 'Daily';
      case GoalType.weekly:
        return 'Weekly';
      case GoalType.monthly:
        return 'Monthly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = consumedCalories >= goal.targetCalories;
    final progress = (goal.targetCalories > 0)
        ? (consumedCalories / goal.targetCalories).clamp(0.0, 1.0)
        : 0.0;

    final startDateFormatted = DateFormat('MMM d').format(goal.startDate);
    final endDateFormatted = DateFormat('MMM d').format(goal.endDate);
    final periodText = _getGoalPeriodText(goal.type);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            theme.colorScheme.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + Icon + Menu
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.emoji_events : Icons.flag_rounded,
                  size: 30,
                  color: isCompleted ? Colors.amber : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Goal: $periodText',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Row: Circular progress + info
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 12.0,
                  animation: true,
                  animationDuration: 800,
                  percent: progress,
                  center: Icon(
                    isCompleted
                        ? Icons.verified_rounded
                        : Icons.local_fire_department_outlined,
                    size: 30,
                    color: isCompleted
                        ? Colors.green
                        : theme.colorScheme.primary,
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  progressColor:
                  isCompleted ? Colors.green : theme.colorScheme.primary,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$startDateFormatted → $endDateFormatted',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Target: ${goal.targetCalories.toInt()} cal',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consumed: $consumedCalories / ${goal.targetCalories.toInt()} cal',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isCompleted
                              ? Colors.green
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Completion message
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Goal Achieved! Keep it up 🚀',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
