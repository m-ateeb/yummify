// lib/features/calorietracker/presentation/widgets/calorie_summary_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/features/calorietracker/domain/calorie_entry.dart';

class CalorieSummaryCard extends StatelessWidget {
  final List<CalorieEntry> entries;

  const CalorieSummaryCard({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries.fold<double>(0, (sum, entry) => sum + entry.calories);
    final totalProtein = entries.fold<double>(0, (sum, entry) => sum + entry.protein);
    final totalFat = entries.fold<double>(0, (sum, entry) => sum + entry.fat);
    final totalCarbs = entries.fold<double>(0, (sum, entry) => sum + entry.carbs);
    final totalFiber = entries.fold<double>(0, (sum, entry) => sum + entry.fiber);

    final double averageCalories = entries.isEmpty ? 0 : totalCalories / entries.length;
    final averageProtein = entries.isEmpty ? 0 : totalProtein / entries.length;
    final averageFat = entries.isEmpty ? 0 : totalFat / entries.length;
    final averageCarbs = entries.isEmpty ? 0 : totalCarbs / entries.length;
    final averageFiber = entries.isEmpty ? 0 : totalFiber / entries.length;

    final List<_InfoCard> cards = [
      _InfoCard(title: 'Total Calories', value: totalCalories, icon: Icons.local_fire_department, color: Colors.redAccent, unit: 'kcal'),
      _InfoCard(title: 'Total Protein', value: totalProtein, icon: Icons.fitness_center, color: Colors.blueAccent, unit: 'g'),
      _InfoCard(title: 'Total Fat', value: totalFat, icon: Icons.oil_barrel, color: Colors.orangeAccent, unit: 'g'),
      _InfoCard(title: 'Total Carbs', value: totalCarbs, icon: Icons.bakery_dining, color: Colors.green, unit: 'g'),
      _InfoCard(title: 'Total Fiber', value: totalFiber, icon: Icons.grass, color: Colors.teal, unit: 'g'),
      _InfoCard(title: 'Avg. Calories', value: averageCalories, icon: Icons.restaurant, color: Colors.purple, unit: 'kcal'),
      // _InfoCard(title: 'Avg. Protein', value: averageProtein, icon: Icons.fitness_center, color: Colors.blue, unit: 'g'),
      // _InfoCard(title: 'Avg. Fat', value: averageFat, icon: Icons.oil_barrel, color: Colors.orange, unit: 'g'),
      // _InfoCard(title: 'Avg. Carbs', value: averageCarbs, icon: Icons.bakery_dining, color: Colors.green, unit: 'g'),
      // _InfoCard(title: 'Avg. Fiber', value: averageFiber, icon: Icons.grass, color: Colors.teal, unit: 'g'),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withAlpha((0.25 * 255).toInt()),
            Theme.of(context).colorScheme.secondaryContainer.withAlpha((0.15 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withAlpha((0.1 * 255).toInt())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calorie Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate width for two cards per row with spacing
              final double cardWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards
                    .map((card) => SizedBox(width: cardWidth, child: card))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          if (entries.isNotEmpty)
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: Theme.of(context).textTheme.bodySmall),
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text((value.toInt() + 1).toString(), style: Theme.of(context).textTheme.bodySmall),
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  barGroups: entries
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.calories,
                          color: e.value.calories > averageCalories
                              ? Colors.green
                              : Colors.red,
                          width: 16,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String unit;

  const _InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}