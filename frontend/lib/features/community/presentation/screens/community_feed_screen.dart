import 'package:flutter/material.dart';
import '/features/community/data/community_repository.dart';
import '/features/community/domain/community_post.dart';
import '/features/community/presentation/screens/add_post_screen.dart';
import '/features/community/presentation/widgets/recipe_feed_tile.dart';

class CommunityFeedScreen extends StatelessWidget {
  final CommunityRepository _repository = CommunityRepository();

  CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: StreamBuilder<List<CommunityPost>>(
        stream: _repository.getCommunityPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data;

          if (posts == null || posts.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => RecipeFeedTile(post: posts[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPostScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
