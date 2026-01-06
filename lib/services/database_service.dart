import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _subsCollection => _db.collection('subscriptions');

  // Add Subscription
  Future<void> addSubscription(Subscription sub) async {
    await _subsCollection.add(sub.toMap());
  }

  // Update Subscription
  Future<void> updateSubscription(Subscription sub) async {
    await _subsCollection.doc(sub.id).update(sub.toMap());
  }

  // Delete Subscription
  Future<void> deleteSubscription(String id) async {
    await _subsCollection.doc(id).delete();
  }

  // Get User Subscriptions Stream
  Stream<List<Subscription>> getUserSubscriptions(String userId) {
    return _subsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subscription.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}