import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 360;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: isNarrow
            ? _buildColumnLayout(context) // Use column layout for narrow screens
            : _buildRowLayout(context),  // Use row layout for wider screens
      ),
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              'Edit',
              Icons.edit,
              Colors.blueAccent,
              isProcessing ? null : onEditProfile,
              'Edit your profile',
            ),
            _buildActionButton(
              context,
              'Password',
              Icons.lock,
              Colors.orange,
              isProcessing ? null : onChangePassword,
              'Change your password',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              'Delete',
              Icons.delete_forever,
              Colors.red,
              isProcessing ? null : onDeleteAccount,
              'Delete your account',
            ),
            _buildActionButton(
              context,
              'Logout',
              Icons.logout,
              Colors.purple,
              isProcessing ? null : () => _handleLogout(context),
              'Log out of your account',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColumnLayout(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Edit',
          Icons.edit,
          Colors.blueAccent,
          isProcessing ? null : onEditProfile,
          'Edit your profile',
          true,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context,
          'Password',
          Icons.lock,
          Colors.orange,
          isProcessing ? null : onChangePassword,
          'Change your password',
          true,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context,
          'Delete',
          Icons.delete_forever,
          Colors.red,
          isProcessing ? null : onDeleteAccount,
          'Delete your account',
          true,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context,
          'Logout',
          Icons.logout,
          Colors.purple,
          isProcessing ? null : () => _handleLogout(context),
          'Log out of your account',
          true,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
    String tooltip, [
    bool fullWidth = false,
  ]) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: color, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: fullWidth ? const Size(double.infinity, 0) : null,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LOGOUT'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();

        // Don't navigate manually - let the auth stream handle it
        // The StreamBuilder in main.dart will detect the auth state change
        // and automatically show the login screen
      } catch (e) {
        // Show error message if logout fails
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error logging out: $e')),
          );
        }
      }
    }
  }
}
