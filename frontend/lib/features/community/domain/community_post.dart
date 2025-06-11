class CommunityPost {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static CommunityPost fromMap(String id, Map<String, dynamic> map) {
    return CommunityPost(
      id: id,
      userId: map['userId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
