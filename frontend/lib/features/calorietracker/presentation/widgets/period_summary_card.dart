// lib/features/calorietracker/presentation/widgets/period_summary_card.dart
import 'package:flutter/material.dart';
import '/features/calorietracker/domain/calorie_entry.dart';

class PeriodSummaryCard extends StatelessWidget {
  final String title;
  final String dateRange;
  final int consumedCalories;

  const PeriodSummaryCard({
    Key? key,
    required this.title,
    required this.dateRange,
    required this.consumedCalories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateRange,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$consumedCalories calories consumed',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}