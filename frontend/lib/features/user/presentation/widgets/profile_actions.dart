import 'package:flutter/material.dart';

class ProfileActions extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePassword;
  final VoidCallback? onDeleteAccount;

  const ProfileActions({
    Key? key,
    required this.isProcessing,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onDeleteAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          onPressed: isProcessing ? null : onEditProfile,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.lock),
          label: const Text('Change Password'),
          onPressed: isProcessing ? null : onChangePassword,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete_forever),
          label: const Text('Delete Account'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: isProcessing ? null : onDeleteAccount,
        ),
      ],
    );
  }
}

