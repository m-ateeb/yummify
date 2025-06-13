import 'package:flutter/material.dart';
import '/features/user/presentation/screens/profile_screen.dart';
import 'package:frontend/features/cookbook/presentation/screens/recipe_detail_screen.dart';
import 'package:frontend/home_screen.dart';
import '/features/auth/presentation/screens/login_screen.dart';
import '/features/auth/presentation/screens/signup_screen.dart';
import '/features/cookbook/presentation/screens/cookbook_screen.dart';
import '/features/community/presentation/screens/community_feed_screen.dart';
import '/features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
import '/features/aichat/presentation/screens/aichat_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/cookbook':
        return MaterialPageRoute(builder: (_) => CookbookScreen());
      case '/community':
        return MaterialPageRoute(builder: (_) => CommunityFeedScreen());
      case '/calorie':
        return MaterialPageRoute(builder: (_) => CalorieTrackerScreen());
      case '/ai':
        return MaterialPageRoute(builder: (_) => const AIChatScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
