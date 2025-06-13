import 'package:flutter/material.dart';
import '../../domain/user_entity.dart';

class ActivityHistory extends StatelessWidget {
  final List<Activity> activities;
  const ActivityHistory({Key? key, required this.activities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Activity History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            activities.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('No activity yet.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (_, __) => const Divider(height: 18),
                    itemBuilder: (context, i) {
                      final activity = activities[i];
                      IconData icon;
                      Color iconColor;
                      switch (activity.type) {
                        case 'liked':
                          icon = Icons.thumb_up;
                          iconColor = Colors.green;
                          break;
                        case 'commented':
                          icon = Icons.comment;
                          iconColor = Colors.blueAccent;
                          break;
                        default:
                          icon = Icons.info_outline;
                          iconColor = theme.colorScheme.primary;
                      }
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconColor.withOpacity(0.12),
                          child: Icon(icon, color: iconColor),
                        ),
                        title: Text(activity.description, style: theme.textTheme.bodyLarge),
                        subtitle: Text(
                          '${activity.timestamp.year}-${activity.timestamp.month.toString().padLeft(2, '0')}-${activity.timestamp.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.08),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
