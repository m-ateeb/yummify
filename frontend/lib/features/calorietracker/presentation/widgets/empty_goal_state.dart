// lib/features/calorietracker/presentation/widgets/empty_goal_view.dart
import 'package:flutter/material.dart';
import '/features/calorietracker/presentation/screens/set_goal_screen.dart';

class EmptyGoalView extends StatelessWidget {
  final String goalType;

  const EmptyGoalView({
    Key? key,
    required this.goalType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(24), // match card shape
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SetGoalScreen(),
            ),
          );
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 20),
                Text(
                  'No $goalType goals set',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Set a $goalType goal to start tracking your progress and stay motivated!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SetGoalScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Set a Goal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
