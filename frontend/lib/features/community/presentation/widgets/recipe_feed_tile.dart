import 'package:flutter/material.dart';
import '/features/community/domain/community_post.dart';

class RecipeFeedTile extends StatelessWidget {
  final CommunityPost post;

  const RecipeFeedTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(post.content),
        subtitle: Text('Posted: ${post.timestamp.toLocal()}'),
        leading: const Icon(Icons.person),
      ),
    );
  }
}
