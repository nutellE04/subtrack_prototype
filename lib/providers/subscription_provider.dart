import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final NotificationService _notifications = NotificationService();
  
  List<Subscription> _subscriptions = [];
  List<Subscription> get subscriptions => _subscriptions;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Initialize listener for real-time updates
  void init() {
    String? uid = _auth.currentUserId;
    if (uid != null) {
      _db.getUserSubscriptions(uid).listen((subs) {
        _subscriptions = subs;
        // Sort by next payment date
        _subscriptions.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
        
        // Refresh notifications logic (optional: re-schedule strictly to keep in sync)
        // For this prototype, we handle scheduling on add/update actions.
        notifyListeners();
      });
    }
  }

  // Calculate Total Monthly Cost
  double get totalMonthlyCost {
    double total = 0;
    for (var sub in _subscriptions) {
      if (sub.billingCycle == 'Monthly') {
        total += sub.cost;
      } else {
        total += sub.cost / 12; // Prorate yearly
      }
    }
    return total;
  }

  // Analytics: Cost by Category
  Map<String, double> get costByCategory {
    Map<String, double> data = {};
    for (var sub in _subscriptions) {
      double monthlyCost = sub.billingCycle == 'Monthly' ? sub.cost : sub.cost / 12;
      
      if (data.containsKey(sub.category)) {
        data[sub.category] = data[sub.category]! + monthlyCost;
      } else {
        data[sub.category] = monthlyCost;
      }
    }
    return data;
  }

  // Helper to manage notification logic
  Future<void> _manageNotification(Subscription sub) async {
    // Unique Int ID for the notification based on the String ID
    int notificationId = sub.id.hashCode;

    // Always cancel existing to be safe (avoid duplicates or stale times)
    await _notifications.cancelNotification(notificationId);

    if (sub.remindMe) {
      // Schedule for the next payment date at 9:00 AM
      DateTime nextDate = sub.nextPaymentDate;
      DateTime scheduledTime = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        9, // 9 AM
        0,
      );

      // If 9 AM today has passed, this logic in the Service will handle skipping it
      // or we could schedule it for the *following* cycle here.
      
      await _notifications.scheduleSubscriptionReminder(
        id: notificationId,
        title: 'Upcoming Payment: ${sub.name}',
        body: 'Your payment of \$${sub.cost} is due today!',
        scheduledDate: scheduledTime,
      );
    }
  }

  Future<void> addSubscription(Subscription sub) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.addSubscription(sub);
      await _manageNotification(sub); // Schedule Notification
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSubscription(Subscription sub) async {
    try {
      await _db.updateSubscription(sub);
      await _manageNotification(sub); // Update Notification
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await _db.deleteSubscription(id);
      await _notifications.cancelNotification(id.hashCode); // Cancel Notification
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}