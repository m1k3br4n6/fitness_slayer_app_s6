import 'package:flutter/material.dart';

enum StoreCategory {
  outfit('Outfits', true),
  weapon('Weapons', false), // future update
  title('Titles', false); // future update

  final String label;
  final bool isLive;
  const StoreCategory(this.label, this.isLive);
}

enum Rarity {
  common('Common', Color(0xFFB08A5F)),
  rare('Rare', Color(0xFF4A90D9)),
  epic('Epic', Color(0xFF9B59D0)),
  legendary('Legendary', Color(0xFFE8A92C));

  final String label;
  final Color color;
  const Rarity(this.label, this.color);
}

// Item user can buy in store
class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final StoreCategory category;
  final Rarity rarity;

  // Optional artwork
  final String? imagePath;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
    this.rarity = Rarity.common,
    this.imagePath,
  });
}

// Items that are currently sold in the store
List<StoreItem> get liveStoreItems =>
    storeCatalog.where((item) => item.category.isLive).toList();

StoreItem? findStoreItem(String? id) {
  for (final item in storeCatalog) {
    if (item.id == id) return item;
  }
  return null;
}

const List<StoreItem> storeCatalog = [
  //Outfit
  StoreItem(
    id: 'outfit_starter_tunic',
    name: 'Starter Tunic',
    description: 'Simple cloth for a slayer just beginning the journey.',
    price: 50,
    icon: Icons.accessibility_new,
    category: StoreCategory.outfit,
    rarity: Rarity.common,
  ),
  StoreItem(
    id: 'outfit_forest_ranger',
    name: 'Forest Ranger',
    description: 'Light leathers for those who train outdoors.',
    price: 120,
    icon: Icons.park,
    category: StoreCategory.outfit,
    rarity: Rarity.common,
  ),
  StoreItem(
    id: 'outfit_iron_guard',
    name: 'Iron Guard Armor',
    description: 'Heavy plating for slayers who never skip leg day.',
    price: 150,
    icon: Icons.shield,
    category: StoreCategory.outfit,
    rarity: Rarity.rare,
  ),
  StoreItem(
    id: 'outfit_shadow_cloak',
    name: 'Shadow Cloak',
    description: 'Light and silent. Perfect for early morning runs.',
    price: 250,
    icon: Icons.checkroom,
    category: StoreCategory.outfit,
    rarity: Rarity.rare,
  ),
  StoreItem(
    id: 'outfit_frost_knight',
    name: 'Frost Knight',
    description: 'Cold steel for slayers who train through winter.',
    price: 350,
    icon: Icons.ac_unit,
    category: StoreCategory.outfit,
    rarity: Rarity.epic,
  ),
  StoreItem(
    id: 'outfit_ember_plate',
    name: 'Ember Plate',
    description: 'Forged in the fire of a 30 day streak.',
    price: 400,
    icon: Icons.local_fire_department,
    category: StoreCategory.outfit,
    rarity: Rarity.epic,
  ),
  StoreItem(
    id: 'outfit_golden_champion',
    name: 'Golden Champion',
    description: 'Worn by slayers at the top of the leaderboard.',
    price: 800,
    icon: Icons.emoji_events,
    category: StoreCategory.outfit,
    rarity: Rarity.legendary,
  ),
  StoreItem(
    id: 'outfit_dragon_slayer',
    name: 'Dragon Slayer',
    description: 'Scales taken from the toughest boss of all.',
    price: 1000,
    icon: Icons.auto_awesome,
    category: StoreCategory.outfit,
    rarity: Rarity.legendary,
  ),

  // Weapons (future update)
  StoreItem(
    id: 'weapon_training_blade',
    name: 'Training Blade',
    description: 'Every legend starts with a basic sword.',
    price: 100,
    icon: Icons.sports_martial_arts,
    category: StoreCategory.weapon,
  ),
  StoreItem(
    id: 'weapon_thunder_axe',
    name: 'Thunder Axe',
    description: 'Crackles with energy after every heavy set.',
    price: 300,
    icon: Icons.bolt,
    category: StoreCategory.weapon,
    rarity: Rarity.rare,
  ),
  StoreItem(
    id: 'weapon_arcane_staff',
    name: 'Arcane Staff',
    description: 'For slayers who recover as hard as they train.',
    price: 350,
    icon: Icons.auto_fix_high,
    category: StoreCategory.weapon,
    rarity: Rarity.epic,
  ),

  // Titles (future update)
  StoreItem(
    id: 'title_iron_will',
    name: 'Iron Will',
    description: 'A title shown on your profile.',
    price: 80,
    icon: Icons.military_tech,
    category: StoreCategory.title,
  ),
  StoreItem(
    id: 'title_dawn_breaker',
    name: 'Dawn Breaker',
    description: 'A title for those who train before sunrise.',
    price: 120,
    icon: Icons.wb_twilight,
    category: StoreCategory.title,
  ),
  StoreItem(
    id: 'title_beast_mode',
    name: 'Beast Mode',
    description: 'A title for those who go all out.',
    price: 200,
    icon: Icons.whatshot,
    category: StoreCategory.title,
    rarity: Rarity.rare,
  ),
];