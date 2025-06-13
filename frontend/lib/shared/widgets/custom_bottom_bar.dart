import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final Function(int) onNav;
  const CustomBottomBar({required this.onNav, Key? key}) : super(key: key);

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
      child: SafeArea(
        top: false,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
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
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomButton({required this.icon, required this.label, required this.onTap, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
