import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import 'subscription_detail_screen.dart';

class SubscriptionListScreen extends StatelessWidget {
  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final subs = subProvider.subscriptions;

    return Scaffold(
      appBar: AppBar(title: const Text('SubTrack')),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Monthly Expenses', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '\$${subProvider.totalMonthlyCost.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${subs.length} Active Subscriptions', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          // List
          Expanded(
            child: subs.isEmpty
                ? const Center(child: Text('No subscriptions yet.'))
                : ListView.builder(
                    itemCount: subs.length,
                    itemBuilder: (context, index) {
                      final sub = subs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(sub.name.isNotEmpty ? sub.name[0].toUpperCase() : '?'),
                          ),
                          title: Text(sub.name),
                          subtitle: Text('Next bill: ${DateFormat('MMM dd').format(sub.nextPaymentDate)}'),
                          trailing: Text(
                            '\$${sub.cost.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onTap: () {
                             // Navigate to DETAIL screen
                             Navigator.push(
                               context, 
                               MaterialPageRoute(
                                 builder: (_) => SubscriptionDetailScreen(subscription: sub)
                               )
                             );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}