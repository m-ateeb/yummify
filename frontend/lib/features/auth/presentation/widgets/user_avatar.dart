import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoURL;
    final fallback = user.email?.substring(0, 1).toUpperCase() ?? '?';

    return CircleAvatar(
      radius: radius,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(fallback, style: TextStyle(fontSize: radius * 0.5))
          : null,
    );
  }
}
