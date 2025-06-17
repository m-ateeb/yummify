import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: CachedNetworkImage and Random were removed as they are not used in this version.
// If you need them for future features (like random recipes with images), re-add them.
// import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:math';

import 'package:frontend/features/recipe/presentation/screens/allrecipes_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/community_recipes.dart';
import 'package:frontend/features/recipe/presentation/screens/my_recipe_screen.dart'; // Import MyRecipesScreen
import 'package:frontend/features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
import 'package:frontend/features/calorietracker/presentation/screens/goal_screen.dart';
import 'package:frontend/features/calorietracker/presentation/screens/set_goal_screen.dart';
import 'package:frontend/features/calorietracker/presentation/widgets/goal_progress_card.dart';
import 'package:frontend/features/calorietracker/data/calorie_tracker_repository.dart';
import 'package:frontend/features/calorietracker/domain/calorie_entry.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_builder_page.dart';
import 'package:frontend/features/user/presentation/screens/profile_screen.dart';
import 'package:frontend/shared/widgets/banner_ad.dart';
// Assuming Goal is defined here based on previous context, crucial for StreamBuilder<List<Goal>>

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerCardController;
  late Animation<double> _headerCardAnimation;

  late AnimationController _rowCardsController;
  late Animation<double> _rowCardsAnimation;

  late AnimationController _actionCardsController;
  late Animation<double> _actionCardsAnimation;

  @override
  void initState() {
    super.initState();

    _headerCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerCardAnimation = CurvedAnimation(parent: _headerCardController, curve: Curves.easeOut);

    _rowCardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _rowCardsAnimation = CurvedAnimation(parent: _rowCardsController, curve: Curves.easeOut);

    _actionCardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _actionCardsAnimation = CurvedAnimation(parent: _actionCardsController, curve: Curves.easeOut);

    _headerCardController.forward();
    Future.delayed(const Duration(milliseconds: 100), () => _rowCardsController.forward());
    Future.delayed(const Duration(milliseconds: 200), () => _actionCardsController.forward());
  }

  @override
  void dispose() {
    _headerCardController.dispose();
    _rowCardsController.dispose();
    _actionCardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlack = Color(0xFF000000);
    const Color primaryWhite = Color(0xFFFFFFFF);
    const Color greyLight = Color(0xFFF5F5F5);
    const Color greyMedium = Color(0xFFE0E0E0);
    const Color greyDarkText = Color(0xFF424242);
    const Color accentGreen = Color(0xFF5A8E5C);

    return Scaffold(
      backgroundColor: primaryWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryWhite,
        title: const Text(
          'Welcome 👋',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: primaryBlack,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: primaryBlack),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Today's Goal Section ---
              _sectionTitle("Today's Goal", primaryBlack),
              FadeTransition(
                opacity: _headerCardAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_headerCardAnimation),
                  child: StreamBuilder<List<Goal>>(
                    stream: ref.watch(calorieTrackerRepositoryProvider).getCurrentGoals(),
                    builder: (context, goalSnap) {
                      if (goalSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryBlack)));
                      }
                      if (goalSnap.hasError) {
                        return _ErrorCard("Error loading goals: ${goalSnap.error}");
                      }
                      if (!goalSnap.hasData || goalSnap.data!.isEmpty) {
                        return _NoGoalCard(
                          onSetGoal: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SetGoalScreen()));
                          },
                          primaryBlack: primaryBlack,
                          greyLight: greyLight,
                          greyMedium: greyMedium,
                          greyDarkText: greyDarkText,
                        );
                      }

                      final goal = goalSnap.data!.first;
                      return StreamBuilder<List<CalorieEntry>>(
                        stream: ref.watch(calorieTrackerRepositoryProvider).getEntriesForDay(DateTime.now()),
                        builder: (context, entrySnap) {
                          final entries = entrySnap.data ?? [];
                          final consumedCalories = entries.fold<double>(0, (sum, e) => sum + e.calories);

                          return GoalProgressCard(
                            goal: goal,
                            consumedCalories: consumedCalories.round(),
                            onEdit: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SetGoalScreen()));
                            },
                            onDelete: () {
                              // TODO: Implement delete goal functionality using CalorieTrackerRepository
                              // A dialog for confirmation would be good here.
                            },
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen()));
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Quick Access Cards ---
              _sectionTitle("Quick Access", primaryBlack),
              FadeTransition(
                opacity: _rowCardsAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_rowCardsAnimation),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Explore Recipes',
                          icon: Icons.menu_book,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllRecipesScreen())),
                          backgroundColor: greyLight,
                          iconColor: primaryBlack,
                          textColor: primaryBlack,
                          borderColor: greyMedium,
                          shadowColor: primaryBlack.withOpacity(0.08),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          label: 'Community Hub',
                          icon: Icons.people_alt,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityRecipeScreen())),
                          backgroundColor: greyLight,
                          iconColor: primaryBlack,
                          textColor: primaryBlack,
                          borderColor: greyMedium,
                          shadowColor: primaryBlack.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Productivity Section (Action Cards) ---
              _sectionTitle("Productivity", primaryBlack),
              FadeTransition(
                opacity: _actionCardsAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_actionCardsAnimation),
                  child: Column(
                    children: [
                      _ActionCard(
                        label: 'Set & Track Your Goals',
                        icon: Icons.flag,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen())),
                        backgroundColor: greyLight,
                        iconColor: accentGreen,
                        textColor: primaryBlack,
                        borderColor: greyMedium,
                        shadowColor: primaryBlack.withOpacity(0.08),
                      ),
                      const SizedBox(height: 16),
                      _ActionCard(
                        label: 'Log Your Meals',
                        icon: Icons.local_fire_department,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalorieTrackerScreen())),
                        backgroundColor: greyLight,
                        iconColor: accentGreen,
                        textColor: primaryBlack,
                        borderColor: greyMedium,
                        shadowColor: primaryBlack.withOpacity(0.08),
                      ),
                      const SizedBox(height: 16),
                      _ActionCard(
                        label: 'Generate Recipes with AI',
                        icon: Icons.psychology_alt,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeBuilderPage())),
                        backgroundColor: greyLight,
                        iconColor: accentGreen,
                        textColor: primaryBlack,
                        borderColor: greyMedium,
                        shadowColor: primaryBlack.withOpacity(0.08),
                      ),
                      const SizedBox(height: 16), // Space before the new card
                      // --- My Recipes Card (Added at the bottom of Productivity section) ---
                      _ActionCard(
                        label: 'My Recipes',
                        icon: Icons.collections_bookmark,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRecipesScreen())),
                        backgroundColor: greyLight,
                        iconColor: accentGreen,
                        textColor: primaryBlack,
                        borderColor: greyMedium,
                        shadowColor: primaryBlack.withOpacity(0.08),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) => Padding(
    padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textColor,
        fontFamily: 'Montserrat',
        letterSpacing: 0.5,
      ),
    ),
  );
}

// --- Reusable Card Widgets (As provided, ensuring consistency) ---

class _InfoCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;

  const _InfoCard({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 24, color: iconColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}

class _NoGoalCard extends StatelessWidget {
  final VoidCallback onSetGoal;
  final Color primaryBlack;
  final Color greyLight;
  final Color greyMedium;
  final Color greyDarkText;

  const _NoGoalCard({
    required this.onSetGoal,
    required this.primaryBlack,
    required this.greyLight,
    required this.greyMedium,
    required this.greyDarkText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: greyLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: greyMedium, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.flag, size: 48, color: primaryBlack),
            const SizedBox(height: 12),
            Text(
              'No goals for today',
              style: TextStyle(
                color: primaryBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set a calorie goal to start tracking your progress!',
              style: TextStyle(
                color: greyDarkText,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Set Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              onPressed: onSetGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.red.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// You might need to add this provider if it's not already defined elsewhere
// This is a common pattern for accessing repositories with Riverpod
final calorieTrackerRepositoryProvider = Provider<CalorieTrackerRepository>((ref) {
  return CalorieTrackerRepository(); // Or inject dependencies if needed
});