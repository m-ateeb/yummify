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
    final totalCalories = entries.fold<int>(0, (sum, entry) => sum + entry.calories);
    final averageCalories = entries.isEmpty ? 0 : totalCalories ~/ entries.length;

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
          Row(
            children: [
              _InfoCard(
                title: 'Total Calories',
                value: totalCalories,
                icon: Icons.local_fire_department,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 16),
              _InfoCard(
                title: 'Avg. per Meal',
                value: averageCalories,
                icon: Icons.restaurant,
                color: Colors.orangeAccent,
              ),
            ],
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
                          toY: e.value.calories.toDouble(),
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
  final int value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(),
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
