import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import 'add_subscription_screen.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to AddSubscriptionScreen in "Edit Mode"
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSubscriptionScreen(subscription: subscription),
                ),
              );
              // Fix mounted before popping the detail screen
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Big Icon
            Center(
              child: CircleAvatar(
                radius: 50,
                // Use withValues(alpha: ...) instead of deprecated withOpacity
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  subscription.name.isNotEmpty ? subscription.name[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Cost
            Text(
              '\$${subscription.cost.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'per ${subscription.billingCycle.toLowerCase()}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Category', subscription.category),
                    const Divider(),
                    _buildDetailRow(context, 'Start Date', DateFormat('MMM dd, yyyy').format(subscription.startDate)),
                    const Divider(),
                    _buildDetailRow(context, 'Next Payment', DateFormat('EEEE, MMM dd').format(subscription.nextPaymentDate)),
                    const Divider(),
                    _buildDetailRow(context, 'Reminders', subscription.remindMe ? 'On' : 'Off'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}