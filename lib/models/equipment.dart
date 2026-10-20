class Equipment {
  final String id;
  final String name;
  final String description;
  final String spriteImagePath;
  final String attackSheetPath;
  final String idleSheetPath;
  final int atkBonus;
  final int hpBonus;
  final double price;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.spriteImagePath,
    required this.attackSheetPath,
    required this.idleSheetPath,
    required this.atkBonus,
    required this.hpBonus,
    required this.price,
  });
}