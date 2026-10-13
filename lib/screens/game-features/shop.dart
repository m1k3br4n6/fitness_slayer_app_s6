import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/store_item.dart';
import 'package:fitness_slayer_01/services/store_service.dart';
import 'package:fitness_slayer_01/widgets/loading.dart';
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

  Future<void> _buy(StoreItem item, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.teal[800],
        title: const Text('Buy this item?', style: TextStyle(color: Colors.white)),
        content: Text(
          '${item.name} costs ${item.price} coins.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Buy', style: TextStyle(color: Colors.tealAccent)),
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
      PurchaseResult.success => 'You bought ${item.name}!',
      PurchaseResult.notEnoughCoins => 'Not enough coins.',
      PurchaseResult.alreadyOwned => 'You already own this item.',
      PurchaseResult.userNotFound => "Couldn't find your profile data.",
      PurchaseResult.failed => 'Something went wrong. Please try again.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userDoc = Provider.of<DocumentSnapshot?>(context);
    final user = Provider.of<myUser?>(context);


    if (userDoc == null || user == null) {
      return Scaffold(backgroundColor: Colors.teal[900], body: Loading());
    }

    final data = userDoc.exists
        ? (userDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{})
        : <String, dynamic>{};
    final coins = (data['coin'] as num?)?.toInt() ?? 0;
    final owned = List<String>.from(data['inventory'] ?? const []);

    final items = _selectedCategory == null
        ? storeCatalog
        : storeCatalog.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.teal[900],
      body: Column(
        children: [
          _CoinBalance(coins: coins),
          _CategoryFilter(
            selected: _selectedCategory,
            onSelected: (category) => setState(() => _selectedCategory = category),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 250,
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
                  isBuying: _buyingItemId == item.id,
                  isBusy: _buyingItemId != null,
                  onBuy: () => _buy(item, user.uid),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Shows ho many coins the user has
class _CoinBalance extends StatelessWidget {
  final int coins;
  const _CoinBalance({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your coins', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '$coins',
                style: const TextStyle(
                  color: Colors.white,
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

// Filter
class _CategoryFilter extends StatelessWidget {
  final StoreCategory? selected;
  final ValueChanged<StoreCategory?> onSelected;

  const _CategoryFilter({required this.selected, required this.onSelected});

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.teal[800],
        selectedColor: Colors.teal[600],
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: isSelected ? Colors.tealAccent : Colors.white70,
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
          for (final category in StoreCategory.values)
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
  final bool isBuying;
  final bool isBusy;
  final VoidCallback onBuy;

  const _ItemCard({
    required this.item,
    required this.coins,
    required this.isOwned,
    required this.isBuying,
    required this.isBusy,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = coins >= item.price;
    final VoidCallback? onPressed = (!isOwned && canAfford && !isBusy) ? onBuy : null;
    final label = isOwned
        ? 'Owned'
        : canAfford
            ? 'Buy'
            : 'Need ${item.price - coins} more';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[800],
        borderRadius: BorderRadius.circular(16),
        border: isOwned ? Border.all(color: Colors.tealAccent, width: 1.5) : null,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.teal[900],
            child: Icon(item.icon, color: Colors.tealAccent, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
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
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '${item.price}',
                style: TextStyle(
                  color: (canAfford || isOwned) ? Colors.white : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.teal[900],
                disabledForegroundColor: isOwned ? Colors.tealAccent : Colors.white38,
                shape: const StadiumBorder(),
              ),
              onPressed: onPressed,
              child: isBuying
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
