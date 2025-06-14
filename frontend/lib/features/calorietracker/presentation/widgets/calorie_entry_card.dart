import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
    final GlobalKey popupKey = GlobalKey();
    void showPopupMenu() {
      final dynamic state = popupKey.currentState;
      state?.showButtonMenu();
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: showPopupMenu,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Icon(
                  _getRandomIcon(),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.mealName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('MMM d, yyyy - h:mm a').format(entry.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '${entry.calories}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('calories', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        Text('Fat: ${entry.fat.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 11)),
                        Text('Carbs: ${entry.carbs.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 11)),
                        Text('Fiber: ${entry.fiber.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Text(
                    //   'Serving: '
                    //       '${entry.servingDescription.isNotEmpty ? entry.servingDescription : 'N/A'}'
                    //       '${(entry.servingSize != null && entry.servingSize!.isNotEmpty) ? ' (${entry.servingSize})' : ''}',
                    //   style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: PopupMenuButton<String>(
                  key: popupKey,
                  onSelected: (value) {
                    if (value == 'edit') onEdit(entry);
                    if (value == 'delete') onDelete(entry);
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
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
