import 'package:flutter/material.dart';

enum StoreCategory {
  outfit('Outfits'),
  weapon('Weapons'),
  title('Titles');

  final String label;
  const StoreCategory(this.label);
}

// Item user can buy in store
class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final StoreCategory category;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
  });
}

// Placeholder catalogue.
const List<StoreItem> storeCatalog = [
  StoreItem(
    id: 'outfit_iron_guard',
    name: 'Iron Guard Armor',
    description: 'Heavy plating for slayers who never skip leg day.',
    price: 150,
    icon: Icons.shield,
    category: StoreCategory.outfit,
  ),
  StoreItem(
    id: 'outfit_shadow_cloak',
    name: 'Shadow Cloak',
    description: 'Light and silent. Perfect for early morning runs.',
    price: 250,
    icon: Icons.checkroom,
    category: StoreCategory.outfit,
  ),
  StoreItem(
    id: 'outfit_ember_plate',
    name: 'Ember Plate',
    description: 'Forged in the fire of a 30 day streak.',
    price: 400,
    icon: Icons.local_fire_department,
    category: StoreCategory.outfit,
  ),
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
  ),
  StoreItem(
    id: 'weapon_arcane_staff',
    name: 'Arcane Staff',
    description: 'For slayers who recover as hard as they train.',
    price: 350,
    icon: Icons.auto_fix_high,
    category: StoreCategory.weapon,
  ),
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
  ),
];
