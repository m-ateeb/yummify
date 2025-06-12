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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No $goalType goals set',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
          ),
        ],
      ),
    );
  }
}