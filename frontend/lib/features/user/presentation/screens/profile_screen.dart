import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/firebase_user_service.dart';
import '../../domain/user_entity.dart';
import '../../data/user_data.dart';

import '/features/user/presentation/widgets/profile_header.dart';
import '/features/user/presentation/widgets/profile_actions.dart';
import '/features/user/presentation/widgets/posts_list.dart';
import '/features/user/presentation/widgets/activity_history.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseUserService userService = FirebaseUserService();
  final UserData mockUserData = UserData();

  String? userId;
  bool useMock = false;
  File? _pickedImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.uid.isNotEmpty) {
      userId = firebaseUser.uid;
      useMock = false;
      _ensureUserInDatabase(firebaseUser);
    } else {
      userId = mockUserData.currentUser.id;
      useMock = true;
    }
  }

  Future<void> _ensureUserInDatabase(User firebaseUser) async {
    final userDoc = await userService.getUserDoc(firebaseUser.uid);
    if (!userDoc.exists) {
      await userService.createUserProfile(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'New User',
        email: firebaseUser.email ?? '',
        avatarUrl: firebaseUser.photoURL,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _isProcessing = true;
        });
        try {
          _pickedImage = File(picked.path);
          if (!useMock) {
            final url = await userService.uploadUserAvatarToCloudinary(_pickedImage!);
            await userService.updateUserProfile(userId!, avatarUrl: url);
          } else {
            await mockUserData.updateUserProfile(avatarUrl: picked.path);
          }
          setState(() {
            _pickedImage = null;
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated.')));
        } catch (e) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update image: $e')));
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image picker failed: ${e.message ?? e.code}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image picker not available or failed: $e')),
      );
    }
  }

  Future<void> _changePassword() async {
    final controller = TextEditingController();
    bool valid = false;
    String? errorText;
    while (!valid) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              errorText: errorText,
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(64)],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().length < 6) {
                  setState(() {
                    errorText = 'Password must be at least 6 characters.';
                  });
                } else {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('CHANGE'),
            ),
          ],
        ),
      );
      if (result == null) return;
      if (result.length >= 6) {
        valid = true;
        setState(() {
          _isProcessing = true;
        });
        try {
          if (!useMock) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await user.updatePassword(result);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated.')));
            }
          } else {
            await mockUserData.updatePassword(result);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated.')));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password: $e')));
        }
        setState(() {
          _isProcessing = false;
        });
      } else {
        errorText = 'Password must be at least 6 characters.';
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _isProcessing = true;
      });
      try {
        if (!useMock) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await userService.deleteUserProfile(user.uid);
            await user.delete();
            await userService.logout();
            if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else {
          await mockUserData.logout();
          if (mounted) Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  Future<void> _editProfile(UserEntity user) async {
    final nameController = TextEditingController(text: user.name);
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'name': nameController.text}),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    if (result != null && result['name'] != null && result['name']!.trim().isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });
      if (useMock) {
        await mockUserData.updateUserProfile(name: result['name']!.trim());
      } else {
        await userService.updateUserProfile(userId!, name: result['name']!.trim());
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget profileContent(UserEntity user, List<Post> posts, List<Activity> activities) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(
            user: user,
            pickedImage: _pickedImage,
            isProcessing: _isProcessing,
            onPickImage: _pickImage,
          ),
          const SizedBox(height: 16),
          ProfileActions(
            isProcessing: _isProcessing,
            onEditProfile: _isProcessing ? null : () => _editProfile(user),
            onChangePassword: _changePassword,
            onDeleteAccount: _deleteAccount,
          ),
          const SizedBox(height: 24),
          PostsList(posts: posts),
          const SizedBox(height: 24),
          ActivityHistory(activities: activities),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: /* Optional blur effect:
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: */
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.9),
                    theme.colorScheme.secondary.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 10),
            child: userId == null
                ? const Center(child: Text('Not logged in'))
                : useMock
                ? FutureBuilder<UserEntity>(
              future: mockUserData.getUser(),
              builder: (context, userSnap) {
                if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
                final user = userSnap.data!;
                return FutureBuilder<List<Post>>(
                  future: mockUserData.getUserPosts(),
                  builder: (context, postSnap) {
                    if (!postSnap.hasData) return const Center(child: CircularProgressIndicator());
                    final posts = postSnap.data!;
                    return FutureBuilder<List<Activity>>(
                      future: mockUserData.getActivityHistory(),
                      builder: (context, actSnap) {
                        if (!actSnap.hasData) return const Center(child: CircularProgressIndicator());
                        final activities = actSnap.data!;
                        return profileContent(user, posts, activities);
                      },
                    );
                  },
                );
              },
            )
                : StreamBuilder<UserEntity?>(
              stream: userService.userStream(userId!),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!userSnap.hasData || userSnap.data == null) {
                  return const Center(child: Text('User profile not found.'));
                }
                final user = userSnap.data!;
                return StreamBuilder<List<Post>>(
                  stream: userService.userPostsStream(userId!),
                  builder: (context, postSnap) {
                    if (!postSnap.hasData) return const Center(child: CircularProgressIndicator());
                    final posts = postSnap.data!;
                    return StreamBuilder<List<Activity>>(
                      stream: userService.activityHistoryStream(userId!),
                      builder: (context, actSnap) {
                        if (!actSnap.hasData) return const Center(child: CircularProgressIndicator());
                        final activities = actSnap.data!;
                        return profileContent(user, posts, activities);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
