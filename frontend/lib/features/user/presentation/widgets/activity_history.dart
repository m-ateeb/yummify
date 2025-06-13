import 'package:flutter/material.dart';
import '../../domain/user_entity.dart';

class ActivityHistory extends StatelessWidget {
  final List<Activity> activities;
  const ActivityHistory({Key? key, required this.activities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity History', style: theme.textTheme.titleMedium),
        activities.isEmpty
            ? const Text('No activity yet.')
            : Column(
                children: activities
                    .map((activity) => ListTile(
                          leading: Icon(activity.type == 'liked' ? Icons.thumb_up : Icons.comment),
                          title: Text(activity.description),
                          subtitle: Text('${activity.timestamp.year}-${activity.timestamp.month.toString().padLeft(2, '0')}-${activity.timestamp.day.toString().padLeft(2, '0')}'),
                        ))
                    .toList(),
              ),
      ],
    );
  }
}

