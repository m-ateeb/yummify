import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_builder_page.dart';
import '/features/user/presentation/screens/profile_screen.dart';
import 'package:frontend/home_screen.dart';
import '/features/auth/presentation/screens/login_screen.dart';
import '/features/auth/presentation/screens/signup_screen.dart';
import '/features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/allrecipes_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/community_recipes.dart';
import 'package:frontend/features/recipe/presentation/screens/my_recipe_screen.dart';
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/community':
        return MaterialPageRoute(builder: (_) => CommunityRecipeScreen());
      case '/calorie':
        return MaterialPageRoute(builder: (_) => CalorieTrackerScreen());
      case '/ai':
        return MaterialPageRoute(builder: (_) => const RecipeBuilderPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/recipe':
        return MaterialPageRoute(builder: (_)=> const AllRecipesScreen());
      case '/my':
        return MaterialPageRoute(builder: (_)=> const MyRecipesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
