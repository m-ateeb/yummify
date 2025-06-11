class CommunityPost {
  final String id;
  final String userId;
  final String recipeId;
  final String comment;
  final DateTime timestamp;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.comment,
    required this.timestamp,
  });

  factory CommunityPost.fromMap(Map<String, dynamic> map, String id) {
    return CommunityPost(
      id: id,
      userId: map['userId'],
      recipeId: map['recipeId'],
      comment: map['comment'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
