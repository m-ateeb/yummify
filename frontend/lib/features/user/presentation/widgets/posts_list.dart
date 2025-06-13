import 'package:flutter/material.dart';
import '../../domain/user_entity.dart';

class PostsList extends StatelessWidget {
  final List<Post> posts;
  const PostsList({Key? key, required this.posts}) : super(key: key);

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
                Icon(Icons.article, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Posts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            posts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('No posts yet.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const Divider(height: 18),
                    itemBuilder: (context, i) {
                      final post = posts[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                          child: Icon(Icons.book, color: theme.colorScheme.primary),
                        ),
                        title: Text(post.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          post.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: Text(
                          '${post.createdAt.year}-${post.createdAt.month.toString().padLeft(2, '0')}-${post.createdAt.day.toString().padLeft(2, '0')}',
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
