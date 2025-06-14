import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '/features/calorietracker/domain/calorie_entry.dart';

class GoalProgressCard extends StatelessWidget {
  final Goal goal;
  final int consumedCalories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const GoalProgressCard({
    Key? key,
    required this.goal,
    required this.consumedCalories,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
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

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 120),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.18),
                theme.colorScheme.primary.withOpacity(0.13),
                theme.colorScheme.secondary.withOpacity(0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.13)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            // Glassmorphism effect
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? Colors.green.withOpacity(0.15) : theme.colorScheme.primary.withOpacity(0.12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isCompleted ? Icons.emoji_events : Icons.flag_rounded,
                        size: 28,
                        color: isCompleted ? Colors.green : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Goal: $periodText',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 54.0,
                      lineWidth: 10.0,
                      animation: true,
                      animationDuration: 800,
                      percent: progress,
                      center: Icon(
                        isCompleted
                            ? Icons.verified_rounded
                            : Icons.local_fire_department_outlined,
                        size: 28,
                        color: isCompleted
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.18),
                      progressColor:
                      isCompleted ? Colors.green : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 22),
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
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
        ),
      ),
    );
  }
}
