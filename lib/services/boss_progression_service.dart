
class BossProgressionService {
  //Base Slayer
  static const int slayerBaseHp = 100;
  static const int slayerBaseDamage = 20;

  // Level Up
  static const int slayerHpGainPerLevel = 10;
  static const int slayerDamageGainPerLevel = 5;

  // Base Boss
  static const int bossBaseHp = 110;
  static const int bossBaseDamage = 25;

  //Growth per Boss Week
  static const int bossHpGainPerWeek = 20;
  static const int bossDamageGainPerWeek = 10;

  //Calculates Slayer Max HP based on Slayer Level: 100 + (Level - 1) * 10
  static int calculateSlayerMaxHp(int level) {
    int lvl = level < 1 ? 1 : level;
    return slayerBaseHp + (lvl - 1) * slayerHpGainPerLevel;
  }

  // Calculates Slayer Attack Damage based on Slayer Level: 20 + (Level - 1) * 5
  static int calculateSlayerDamage(int level) {
    int lvl = level < 1 ? 1 : level;
    return slayerBaseDamage + (lvl - 1) * slayerDamageGainPerLevel;
  }

  // Calculates Week Number based on account creation date
  static int calculateWeekNumber(DateTime? registrationDate, {DateTime? currentDate}) {
    if (registrationDate == null) return 1;
    final now = currentDate ?? DateTime.now();
    int days = now.difference(registrationDate).inDays;
    if (days < 0) days = 0;
    return (days ~/ 7) + 1;
  }

  // Calculates Boss Max HP based on Week Number: 110 + (Week - 1) * 20
  static int calculateBossMaxHp(int weekNumber) {
    int w = weekNumber < 1 ? 1 : weekNumber;
    return bossBaseHp + (w - 1) * bossHpGainPerWeek;
  }

  // Calculates Boss Attack Damage based on Week Number: 25 + (Week - 1) * 10
  static int calculateBossDamage(int weekNumber) {
    int w = weekNumber < 1 ? 1 : weekNumber;
    return bossBaseDamage + (w - 1) * bossDamageGainPerWeek;
  }
}
