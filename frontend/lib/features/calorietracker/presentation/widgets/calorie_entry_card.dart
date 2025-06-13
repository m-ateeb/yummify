// lib/features/calorietracker/presentation/widgets/calorie_entry_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/features/calorietracker/domain/calorie_entry.dart';
import 'dart:math';


//calorie detail card
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

  static const List<IconData> _iconChoices = [
    Icons.fastfood,
    Icons.restaurant,
    Icons.emoji_food_beverage,
    Icons.lunch_dining,
  ];

  IconData _getRandomIcon() {
    final random = Random(entry.hashCode);
    return _iconChoices[random.nextInt(_iconChoices.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(_getRandomIcon()),
            ),
            title: Text(
              entry.mealName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

// Inside the subtitle of ListTile in CalorieEntryCard
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy - h:mm a').format(entry.timestamp),
                ),
                const SizedBox(height: 8),
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FixedColumnWidth(8),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(children: [
                      const Text('Calories:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(),
                      Text('${entry.calories.toStringAsFixed(1)} kcal'),
                    ]),
                    TableRow(children: [
                      const Text('Protein:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(),
                      Text('${entry.protein.toStringAsFixed(1)} g'),
                    ]),
                    TableRow(children: [
                      const Text('Fat:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(),
                      Text('${entry.fat.toStringAsFixed(1)} g'),
                    ]),
                    TableRow(children: [
                      const Text('Carbs:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(),
                      Text('${entry.carbs.toStringAsFixed(1)} g'),
                    ]),
                    TableRow(children: [
                      const Text('Fiber:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(),
                      Text('${entry.fiber.toStringAsFixed(1)} g'),
                    ]),
                  ],
                ),
              ],
            ),
            trailing: null, // Remove trailing, dots are now at the top
            onTap: () {
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
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(entry);
                } else if (value == 'delete') {
                  onDelete(entry);
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
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}