import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/subscription_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context);
    final data = provider.costByCategory;
    
    // Colors for charts
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: data.isEmpty 
        ? const Center(child: Text('Add subscriptions to see analytics'))
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Cost by Category (Monthly)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: data.entries.map((entry) {
                        final index = data.keys.toList().indexOf(entry.key);
                        return PieChartSectionData(
                          value: entry.value,
                          title: '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
                          color: colors[index % colors.length],
                          radius: 100,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Legend
                ...data.entries.map((e) {
                  final index = data.keys.toList().indexOf(e.key);
                   return ListTile(
                     leading: CircleAvatar(backgroundColor: colors[index % colors.length], radius: 8),
                     title: Text(e.key),
                     trailing: Text('\$${e.value.toStringAsFixed(2)}/mo'),
                   );
                }),
              ],
            ),
          ),
    );
  }
}