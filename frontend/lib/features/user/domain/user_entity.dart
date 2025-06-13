class UserEntity {
  final String id;
  String name;
  String email;
  String? avatarUrl;
  DateTime memberSince;
  DateTime lastUpdated;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.memberSince,
    required this.lastUpdated,
  });
}

class Post {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

class Activity {
  final String id;
  final String type; // e.g., 'liked', 'commented'
  final String description;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}