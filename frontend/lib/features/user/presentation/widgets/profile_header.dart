import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final File? pickedImage;
  final bool isProcessing;
  final VoidCallback? onPickImage;

  const ProfileHeader({
    Key? key,
    required this.user,
    required this.pickedImage,
    required this.isProcessing,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withOpacity(0.08), theme.colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  backgroundImage: pickedImage != null
                      ? FileImage(pickedImage!)
                      : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!) as ImageProvider
                          : null),
                  child: (pickedImage == null && (user.avatarUrl == null || user.avatarUrl!.isEmpty))
                      ? Icon(Icons.person, size: 56, color: theme.colorScheme.primary)
                      : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Material(
                    color: theme.colorScheme.primary,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: isProcessing ? null : onPickImage,
                      tooltip: 'Change Profile Image',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              user.name.isNotEmpty ? user.name : 'No Name',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              user.email.isNotEmpty ? user.email : 'No Email',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Member since: ${user.memberSince.year}-${user.memberSince.month.toString().padLeft(2, '0')}-${user.memberSince.day.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
