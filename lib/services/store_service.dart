import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/store_item.dart';
import 'package:flutter/foundation.dart';

enum PurchaseResult { success, notEnoughCoins, alreadyOwned, userNotFound, failed } //defines possible purchase outcomes

//handles buying store items.
class StoreService {
  final String uid;
  StoreService({required this.uid}); //uses user's firebase uid

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //purchase an item, deduct coins, and add it to the inventory.
  Future<PurchaseResult> purchase(StoreItem item) async {
    if (item.price < 0) {
      return PurchaseResult.failed;
    }

    final userRef = _db.collection('users').doc(uid);
    final inventoryRef = userRef.collection('inventory').doc(item.id);

    try {
      return await _db.runTransaction<PurchaseResult>((transaction) async {
          //read both documents before making any writes.
          final userSnapshot = await transaction.get(userRef);
          if (!userSnapshot.exists) {return PurchaseResult.userNotFound;}

          final inventorySnapshot = await transaction.get(inventoryRef);
          if (inventorySnapshot.exists) {return PurchaseResult.alreadyOwned;}

          final data = userSnapshot.data() ?? <String, dynamic>{};
          final coins = (data['coin'] as num?)?.toInt() ?? 0;

          if (coins < item.price) {
            return PurchaseResult.notEnoughCoins;
          }

          //deduct coins from the user.
          transaction.update(userRef, {
            'coin': coins - item.price,
          });

          //add the item to the inventory subcollection.
          transaction.set(inventoryRef, {
            'item_id': item.id,
          });

          return PurchaseResult.success;
        },
      );
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return PurchaseResult.failed;
    }
  }
}
