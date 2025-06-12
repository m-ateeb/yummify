// import 'package:flutter/material.dart';
// import '/features/community/data/community_repository.dart';
// import '/features/community/domain/community_post.dart';
//
// class AddPostScreen extends StatefulWidget {
//   const AddPostScreen({super.key});
//
//   @override
//   State<AddPostScreen> createState() => _AddPostScreenState();
// }
//
// class _AddPostScreenState extends State<AddPostScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final CommunityRepository _repository = CommunityRepository();
//
//   bool _isLoading = false;
//
//   void _submitPost() async {
//     if (_controller.text.trim().isEmpty) return;
//
//     setState(() => _isLoading = true);
//
//     final post = CommunityPost(
//       id: '',
//       userId: 'userId-placeholder', // replace with actual user ID
//       content: _controller.text.trim(),
//       timestamp: DateTime.now(),
//     );
//
//     await _repository.addPost(post);
//
//     setState(() => _isLoading = false);
//     Navigator.pop(context);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Post')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               maxLines: 5,
//               decoration: const InputDecoration(
//                 hintText: 'Share something with the community...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _submitPost,
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Post'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '/features/community/data/community_repository.dart';
import '/features/community/domain/community_post.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _controller = TextEditingController();
  final CommunityRepository _repository = CommunityRepository();

  bool _isLoading = false;

  void _submitPost() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final post = CommunityPost(
      id: '',
      userId: '', // Leave empty; repository will set userId
      content: _controller.text.trim(),
      timestamp: DateTime.now(),
    );

    await _repository.addPost(post);

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share something with the community...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}