import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/store_item.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/services/store_service.dart';
import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  String? _buyingItemId;
  late Future<List<StoreItem>> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = StoreItem.fetchCatalog();
  }

  void _retryCatalogLoad() {
    setState(() {
      _catalogFuture = StoreItem.fetchCatalog();
    });
  }

  void _toast(String message) {ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );}

  Future<void> _buy(StoreItem item, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Buy this item?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '${item.name} costs ${item.price} coins.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Buy', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _buyingItemId = item.id);
    final result = await StoreService(uid: uid).purchase(item);
    if (!mounted) return;
    setState(() => _buyingItemId = null);

    final message = switch (result) {
      PurchaseResult.success => 'You bought ${item.name}! Tap Equip to wear it.',
      PurchaseResult.notEnoughCoins => 'Not enough coins.',
      PurchaseResult.alreadyOwned => 'You already own this item.',
      PurchaseResult.userNotFound => "Couldn't find your profile data.",
      PurchaseResult.failed => 'Something went wrong. Please try again.',
    };
    _toast(message);
  }

  Future<void> _equip(StoreItem item, String uid) async {
    try {
      await DatabaseService().setEquipped(uid, item.id);
      if (!mounted) return;
      _toast('${item.name} equipped!');
    } catch (e) {
      if (!mounted) return;
      _toast('Could not equip that outfit. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDoc = Provider.of<DocumentSnapshot?>(context);
    final user = Provider.of<myUser?>(context);

    if (userDoc == null || user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Loading(),
      );
    }

    final userData =
        userDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    final coins = (userData['coin'] as num?)?.toInt() ?? 0;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _CoinBalance(coins: coins),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Equipment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StoreItem>>(
              future: _catalogFuture,
              builder: (context, catalogSnapshot) {
                if (catalogSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Loading();
                }

                if (catalogSnapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Could not load the store.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _retryCatalogLoad,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final items = catalogSnapshot.data ?? <StoreItem>[];

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items available right now.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: userRef.collection('inventory').snapshots(),
                  builder: (context, inventorySnapshot) {
                    if (inventorySnapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Could not load your inventory.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    if (!inventorySnapshot.hasData) {
                      return Loading();
                    }

                    final ownedIds = inventorySnapshot.data!.docs
                        .map((doc) => doc.id)
                        .toSet();


                    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: userRef
                          .collection('slayer')
                          .doc('SO1')
                          .snapshots(),
                      builder: (context, slayerSnapshot) {
                        if (slayerSnapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Could not load equipped item.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        if (!slayerSnapshot.hasData) {
                          return Loading();
                        }

                        final slayerData = slayerSnapshot.data!.data();
                        final equippedItemId =
                        slayerData?['item_equipped'] as String?;

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisExtent: 290,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isOwned = ownedIds.contains(item.id);

                            return _ItemCard(
                              item: item,
                              coins: coins,
                              isOwned: isOwned,
                              isEquipped: equippedItemId == item.id,
                              isBuying: _buyingItemId == item.id,
                              isBusy: _buyingItemId != null,
                              onBuy: () => _buy(item, user.uid),
                              onEquip: () => _equip(item, user.uid),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinBalance extends StatelessWidget {
  final int coins;
  const _CoinBalance({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: AppColors.gold, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your coins', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text(
                '$coins',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final StoreItem item;
  final int coins;
  final bool isOwned;
  final bool isEquipped;
  final bool isBuying;
  final bool isBusy;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const _ItemCard({
    required this.item,
    required this.coins,
    required this.isOwned,
    required this.isEquipped,
    required this.isBuying,
    required this.isBusy,
    required this.onBuy,
    required this.onEquip,
  });

  Widget _art() {
    if (item.imagePath.isEmpty) {
      return const Text(
        'Image missing',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      );
    }

    return ClipOval(
      child: Image.asset(
        item.imagePath,
        width: 64,
        height: 64,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            'Image unavailable',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = coins >= item.price;

    final String label;
    final VoidCallback? onPressed;
    if (isOwned) {
      label = isEquipped ? 'Equipped' : 'Equip';
      onPressed = (!isEquipped && !isBusy) ? onEquip : null;
    } else {
      label = canAfford ? 'Buy' : 'Need ${item.price - coins} more';
      onPressed = (canAfford && !isBusy) ? onBuy : null;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isEquipped
            ? Border.all(color: AppColors.gold, width: 3.5) : isOwned
            ? Border.all(color: AppColors.gold, width: 2.5)
            : Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.container,
            child: _art(),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          if (!isOwned)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.gold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${item.price}',
                  style: TextStyle(
                    color: canAfford ? AppColors.textPrimary : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Owned',
              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.container,
                disabledForegroundColor: isOwned ? AppColors.gold : AppColors.textMuted,
                shape: const StadiumBorder(),
              ),
              onPressed: onPressed,
              child: isBuying
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
              )
                  : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}