import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/store_item.dart';
import 'package:flutter/foundation.dart';

enum PurchaseResult { success, notEnoughCoins, alreadyOwned, userNotFound, failed }

// Handles buying store items.
class StoreService {
  final String uid;
  StoreService({required this.uid});

  final CollectionReference<Map<String, dynamic>> _userCollection =
      FirebaseFirestore.instance.collection('test_users');

  // Removes the coins the user has, and adds item to their inventory
  Future<PurchaseResult> purchase(StoreItem item) async {
    final userRef = _userCollection.doc(uid);

    try {
      return await FirebaseFirestore.instance.runTransaction<PurchaseResult>((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return PurchaseResult.userNotFound;

        final data = snapshot.data() ?? <String, dynamic>{};
        final coins = (data['coin'] as num?)?.toInt() ?? 0;
        final inventory = List<String>.from(data['inventory'] ?? const []);

        if (inventory.contains(item.id)) return PurchaseResult.alreadyOwned;
        if (coins < item.price) return PurchaseResult.notEnoughCoins;

        transaction.update(userRef, {
          'coin': coins - item.price,
          'inventory': FieldValue.arrayUnion([item.id]),
        });
        return PurchaseResult.success;
      });
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return PurchaseResult.failed;
    }
  }
}
