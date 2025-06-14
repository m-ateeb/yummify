import 'package:flutter/material.dart';
import 'features/cookbook/presentation/screens/cookbook_screen.dart';
import 'features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
import 'features/user/presentation/screens/profile_screen.dart';
import '/features/calorietracker/presentation/widgets/goal_progress_card.dart';
import '/features/calorietracker/data/calorie_tracker_repository.dart';
import 'features/calorietracker/presentation/screens/goal_screen.dart';
import 'features/calorietracker/presentation/screens/set_goal_screen.dart';
import '/features/calorietracker/domain/calorie_entry.dart';
//import 'shared/widgets/custom_bottom_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          'Welcome 👋',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () => Navigator.pop(context),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              StreamBuilder<List<Goal>>(
                stream: CalorieTrackerRepository().getCurrentGoals(),
                builder: (context, goalSnap) {
                  if (!goalSnap.hasData) {
                    return const SizedBox.shrink();
                  }
                  if (goalSnap.data == null || goalSnap.data!.isEmpty) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.flag, size: 48, color: colorScheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              'No goals for today',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Set a calorie goal to start tracking your progress!',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Set Goal'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SetGoalScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final goal = goalSnap.data!.first;
                  return StreamBuilder<List<CalorieEntry>>(
                    stream: CalorieTrackerRepository().getEntriesForDay(DateTime.now()),
                    builder: (context, entrySnap) {
                      final entries = entrySnap.data ?? [];
                      final consumedCalories = entries.fold<double>(0, (sum, e) => sum + e.calories);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GoalScreen()),
                          );
                        },
                        child: GoalProgressCard(
                          goal: goal,
                          consumedCalories: consumedCalories.round(),
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SetGoalScreen()),
                            );
                          },
                          onDelete: () {},
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GoalScreen()),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _NavTile(
                      label: 'Login',
                      icon: Icons.login,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      color: colorScheme.primaryContainer,
                    ),
                    _NavTile(
                      label: 'Sign Up',
                      icon: Icons.person_add_alt,
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      color: colorScheme.secondaryContainer,
                    ),
                    _NavTile(
                      label: 'Recipes',
                      icon: Icons.menu_book,
                      onTap: () => Navigator.pushNamed(context, '/cookbook'),
                      color: Colors.deepPurpleAccent.withOpacity(0.1),
                    ),
                    _NavTile(
                      label: 'Calorie Tracker',
                      icon: Icons.local_fire_department,
                      onTap: () => Navigator.pushNamed(context, '/calorie'),
                      color: Colors.orangeAccent.withOpacity(0.1),
                    ),
                    _NavTile(
                      label: 'Goal',
                      icon: Icons.flag,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GoalScreen()),
                      ),
                      color: Colors.pinkAccent.withOpacity(0.1),
                    ),
                    _NavTile(
                      label: 'AI Chat',
                      icon: Icons.chat_bubble_outline,
                      onTap: () => Navigator.pushNamed(context, '/ai'),
                      color: Colors.lightBlue.withOpacity(0.1),
                    ),
                    _NavTile(
                      label: 'Profile',
                      icon: Icons.person,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      color: Colors.greenAccent.withOpacity(0.1),
                    ),
                    _NavTile(
                      label: 'Community',
                      icon: Icons.person,
                      onTap: () => Navigator.pushNamed(context, '/community'),
                      color: Colors.greenAccent.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomBar(
      //   onNav: (index) {
      //     switch (index) {
      //       case 0:
      //         break; // Already on Home
      //       case 1:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => const CookbookScreen()),
      //         );
      //         break;
      //       case 2:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => const CalorieTrackerScreen()),
      //         );
      //         break;
      //       case 3:
      //         _navigateTo(context, const ProfileScreen());
      //         break;
      //     }
      //   },
      // ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _NavTile({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: () {
        // Use direct navigation for known screens, otherwise fallback to pushNamed
        if (label == 'Recipes') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CookbookScreen()),
          );
        } else if (label == 'Calorie Tracker') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalorieTrackerScreen()),
          );
        } else if (label == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else {
          onTap();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: textColor),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}