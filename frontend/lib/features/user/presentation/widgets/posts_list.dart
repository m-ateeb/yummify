import 'package:flutter/material.dart';
import '../../domain/user_entity.dart';

class PostsList extends StatelessWidget {
  final List<Post> posts;
  const PostsList({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posts', style: theme.textTheme.titleMedium),
        posts.isEmpty
            ? const Text('No posts yet.')
            : Column(
                children: posts
                    .map((post) => ListTile(
                          title: Text(post.title),
                          subtitle: Text(post.content),
                          trailing: Text('${post.createdAt.year}-${post.createdAt.month.toString().padLeft(2, '0')}-${post.createdAt.day.toString().padLeft(2, '0')}'),
                        ))
                    .toList(),
              ),
      ],
    );
  }
}

