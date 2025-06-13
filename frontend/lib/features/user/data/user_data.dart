import '../domain/user_entity.dart';

class UserData {
  // Simulated user data
  UserEntity currentUser = UserEntity(
    id: '1',
    name: 'John Doe',
    email: 'johndoe@email.com',
    avatarUrl: null,
    memberSince: DateTime(2024, 1, 1),
    lastUpdated: DateTime.now(),
  );

  List<Post> userPosts = [
    Post(id: 'p1', title: 'First Post', content: 'Hello world!', createdAt: DateTime.now().subtract(Duration(days: 10))),
    Post(id: 'p2', title: 'Second Post', content: 'Flutter is awesome!', createdAt: DateTime.now().subtract(Duration(days: 5))),
  ];

  List<Activity> activityHistory = [
    Activity(id: 'a1', type: 'liked', description: 'Liked "First Post"', timestamp: DateTime.now().subtract(Duration(days: 9))),
    Activity(id: 'a2', type: 'commented', description: 'Commented on "Second Post"', timestamp: DateTime.now().subtract(Duration(days: 4))),
  ];

  Future<UserEntity> getUser() async => currentUser;

  Future<List<Post>> getUserPosts() async => userPosts;

  Future<List<Activity>> getActivityHistory() async => activityHistory;

  Future<void> updateUserProfile({String? name, String? avatarUrl}) async {
    if (name != null) currentUser.name = name;
    if (avatarUrl != null) currentUser.avatarUrl = avatarUrl;
    currentUser.lastUpdated = DateTime.now();
  }

  Future<void> updatePassword(String newPassword) async {
    // Simulate password update
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> logout() async {
    // Simulate logout
    await Future.delayed(Duration(milliseconds: 300));
  }
}