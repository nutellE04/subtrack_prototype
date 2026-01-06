import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;
  final String userId;
  final String name;
  final double cost;
  final String billingCycle; // 'Monthly', 'Yearly'
  final DateTime startDate;
  final String category; // 'Entertainment', 'Utilities', 'Work', 'Other'
  final bool remindMe;

  Subscription({
    required this.id,
    required this.userId,
    required this.name,
    required this.cost,
    required this.billingCycle,
    required this.startDate,
    required this.category,
    this.remindMe = false,
  });

  // Calculate next payment date
  DateTime get nextPaymentDate {
    DateTime now = DateTime.now();
    DateTime nextDate = startDate;

    while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      if (billingCycle == 'Monthly') {
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
      } else {
        nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
      }
    }
    return nextDate;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'cost': cost,
      'billingCycle': billingCycle,
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'remindMe': remindMe,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map, String docId) {
    return Subscription(
      id: docId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Unnamed',
      cost: (map['cost'] ?? 0.0).toDouble(),
      billingCycle: map['billingCycle'] ?? 'Monthly',
      startDate: (map['startDate'] as Timestamp).toDate(),
      category: map['category'] ?? 'Other',
      remindMe: map['remindMe'] ?? false,
    );
  }
}