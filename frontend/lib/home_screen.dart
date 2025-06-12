// import 'package:flutter/material.dart';
// import '/features/recipe/presentation/screens/recipedetail_screen.dart';
// import '/features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
// import 'features/user/presentation/screens/profile_screen.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   void _navigateTo(BuildContext context, Widget screen) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => screen),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: ListView(
//           children: [
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/login'),
//               child: const Text('Login Screen'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/signup'),
//               child: const Text('Sign Up Screen'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context,  '/cookbook'),
//               child: const Text('Recipe Screen'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context,'/calorie'),
//               child: const Text('Calorie Tracker Screen'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/ai'),
//               child: const Text('AI Chat Screen'),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _BottomNavItem(
//               icon: Icons.home,
//               label: 'Home',
//               onTap: () {}, // Already on Home
//             ),
//             _BottomNavItem(
//               icon: Icons.menu_book,
//               label: 'Recipe',
//               onTap: () => Navigator.pushNamed(context,  '/cookbook'),
//             ),
//             _BottomNavItem(
//               icon: Icons.local_fire_department,
//               label: 'Calorie',
//               onTap: () => Navigator.pushNamed(context,'/calorie'),
//             ),
//             _BottomNavItem(
//               icon: Icons.person,
//               label: 'Profile',
//               onTap: () => _navigateTo(context, const ProfileScreen()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _BottomNavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   const _BottomNavItem({
//     Key? key,
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: onTap,
//       style: TextButton.styleFrom(foregroundColor: Colors.grey[800]),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'features/cookbook/presentation/screens/cookbook_screen.dart';
import 'features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
import 'features/user/presentation/screens/profile_screen.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
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
              onTap: () => Navigator.pushNamed(context,  '/cookbook'),
              color: Colors.deepPurpleAccent.withOpacity(0.1),
            ),
            _NavTile(
              label: 'Calorie Tracker',
              icon: Icons.local_fire_department,
              onTap: () => Navigator.pushNamed(context,  '/calorie'),
              color: Colors.orangeAccent.withOpacity(0.1),
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
              onTap: () => Navigator.pushNamed(context,  '/profile'),
              color: Colors.greenAccent.withOpacity(0.1),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CustomBottomBar(
        onNav: (index) {
          switch (index) {
            case 0:
              break; // Already on Home
            case 1:
          Navigator.pushNamed(context,  '/cookbook');
              break;
            case 2:
              Navigator.pushNamed(context,  '/calorie');
              break;
            case 3:
              _navigateTo(context, const ProfileScreen());
              break;
          }
        },
      ),
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
      onTap: onTap,
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

class _CustomBottomBar extends StatelessWidget {
  final Function(int) onNav;

  const _CustomBottomBar({required this.onNav, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomButton(icon: Icons.home, label: 'Home', onTap: () => onNav(0)),
              _BottomButton(icon: Icons.menu_book, label: 'Recipe', onTap: () => onNav(1)),
              _BottomButton(icon: Icons.local_fire_department, label: 'Calorie', onTap: () => onNav(2)),
              _BottomButton(icon: Icons.person, label: 'Profile', onTap: () => onNav(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(  // This fixes the vertical overflow
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

