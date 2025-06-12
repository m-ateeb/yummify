class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profilePicUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePicUrl,
  });

  // Convert a Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profilePicUrl: map['profilePicUrl'],
    );
  }

  // Convert UserModel to Firestore-friendly format
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePicUrl': profilePicUrl,
    };
  }
}
