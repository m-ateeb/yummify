// lib/features/calorietracker/presentation/widgets/calorie_entry_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/features/calorietracker/domain/calorie_entry.dart';

class CalorieEntryCard extends StatelessWidget {
  final CalorieEntry entry;
  final Function(CalorieEntry) onEdit;
  final Function(CalorieEntry) onDelete;

  const CalorieEntryCard({
    Key? key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.fastfood),
        ),
        title: Text(
          entry.mealName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy - h:mm a').format(entry.timestamp),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.calories}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('calories'),
          ],
        ),
        onTap: () {
          // Show options: Edit or Delete
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Entry'),
                      onTap: () {
                        Navigator.pop(context);
                        onEdit(entry);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete Entry'),
                      onTap: () {
                        Navigator.pop(context);
                        onDelete(entry);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}