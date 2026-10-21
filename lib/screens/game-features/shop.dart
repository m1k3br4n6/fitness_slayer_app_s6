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
  StoreCategory? _selectedCategory;
  String? _buyingItemId;

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
      await DatabaseService().setEquippedOutfit(uid, item.id);
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
      return Scaffold(backgroundColor: AppColors.background, body: Loading());
    }

    final data = userDoc.exists
        ? (userDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{})
        : <String, dynamic>{};
    final coins = (data['coin'] as num?)?.toInt() ?? 0;
    final owned = List<String>.from(data['inventory'] ?? const []);
    final equippedOutfit = data['equipped_outfit'] as String?;

    // Only categories marked isLive are sold. Others are kept for future updates.
    final liveCategories = StoreCategory.values.where((c) => c.isLive).toList();
    final items = liveStoreItems
        .where((item) => _selectedCategory == null || item.category == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _CoinBalance(coins: coins),
          if (liveCategories.length > 1)
            _CategoryFilter(
              categories: liveCategories,
              selected: _selectedCategory,
              onSelected: (category) => setState(() => _selectedCategory = category),
            )
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Outfits',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 290,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _ItemCard(
                  item: item,
                  coins: coins,
                  isOwned: owned.contains(item.id),
                  isEquipped: equippedOutfit == item.id,
                  isBuying: _buyingItemId == item.id,
                  isBusy: _buyingItemId != null,
                  onBuy: () => _buy(item, user.uid),
                  onEquip: () => _equip(item, user.uid),
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

class _CategoryFilter extends StatelessWidget {
  final List<StoreCategory> categories;
  final StoreCategory? selected;
  final ValueChanged<StoreCategory?> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.secondary,
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip('All', selected == null, () => onSelected(null)),
          for (final category in categories)
            _chip(category.label, selected == category, () => onSelected(category)),
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
    final fallback = Icon(item.icon, color: AppColors.gold, size: 30);
    if (item.imagePath == null) return fallback;
    return ClipOval(
      child: Image.asset(
        item.imagePath!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => fallback,
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
            ? Border.all(color: AppColors.gold, width: 2)
            : isOwned
            ? Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5)
            : Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.rarity.label,
            style: TextStyle(
              color: item.rarity.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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