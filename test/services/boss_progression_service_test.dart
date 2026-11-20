import 'package:fitness_slayer_01/services/boss_progression_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BossProgressionService - Constants', () {
    test('slayer and boss base stats and growth constants match progression design', () {
      expect(BossProgressionService.slayerBaseHp, equals(100));
      expect(BossProgressionService.slayerBaseDamage, equals(20));
      expect(BossProgressionService.slayerHpGainPerLevel, equals(10));
      expect(BossProgressionService.slayerDamageGainPerLevel, equals(5));

      expect(BossProgressionService.bossBaseHp, equals(110));
      expect(BossProgressionService.bossBaseDamage, equals(25));
      expect(BossProgressionService.bossHpGainPerWeek, equals(20));
      expect(BossProgressionService.bossDamageGainPerWeek, equals(10));
    });
  });

  group('BossProgressionService - calculateSlayerMaxHp (100 + (lvl - 1) * 10)', () {
    test('level 1 base Slayer Max HP is 100', () {
      expect(BossProgressionService.calculateSlayerMaxHp(1), equals(100));
    });

    test('level 2 Slayer Max HP is 110', () {
      expect(BossProgressionService.calculateSlayerMaxHp(2), equals(110));
    });

    test('level 5 Slayer Max HP is 140', () {
      // 100 + (5 - 1) * 10 = 140
      expect(BossProgressionService.calculateSlayerMaxHp(5), equals(140));
    });

    test('level 10 Slayer Max HP is 190', () {
      // 100 + (10 - 1) * 10 = 190
      expect(BossProgressionService.calculateSlayerMaxHp(10), equals(190));
    });

    test('high level scaling (level 50 and 100)', () {
      expect(BossProgressionService.calculateSlayerMaxHp(50), equals(590));
      expect(BossProgressionService.calculateSlayerMaxHp(100), equals(1090));
    });

    test('edge case: level 0 or negative clamped to level 1 baseline (100 HP)', () {
      expect(BossProgressionService.calculateSlayerMaxHp(0), equals(100));
      expect(BossProgressionService.calculateSlayerMaxHp(-5), equals(100));
    });
  });

  group('BossProgressionService - calculateSlayerDamage (20 + (lvl - 1) * 5)', () {
    test('level 1 base Slayer Damage is 20', () {
      expect(BossProgressionService.calculateSlayerDamage(1), equals(20));
    });

    test('level 2 Slayer Damage is 25', () {
      expect(BossProgressionService.calculateSlayerDamage(2), equals(25));
    });

    test('level 5 Slayer Damage is 40', () {
      // 20 + (5 - 1) * 5 = 40
      expect(BossProgressionService.calculateSlayerDamage(5), equals(40));
    });

    test('level 10 Slayer Damage is 65', () {
      // 20 + (10 - 1) * 5 = 65
      expect(BossProgressionService.calculateSlayerDamage(10), equals(65));
    });

    test('high level scaling (level 50 and 100)', () {
      expect(BossProgressionService.calculateSlayerDamage(50), equals(265));
      expect(BossProgressionService.calculateSlayerDamage(100), equals(515));
    });

    test('edge case: level 0 or negative clamped to level 1 baseline (20 ATK)', () {
      expect(BossProgressionService.calculateSlayerDamage(0), equals(20));
      expect(BossProgressionService.calculateSlayerDamage(-3), equals(20));
    });
  });

  group('BossProgressionService - calculateWeekNumber ((days ~/ 7) + 1)', () {
    test('null registrationDate returns Week 1', () {
      expect(BossProgressionService.calculateWeekNumber(null), equals(1));
    });

    test('currentDate before registrationDate (negative days) clamps to Week 1', () {
      final regDate = DateTime(2026, 5, 10);
      final currentDate = DateTime(2026, 5, 5); // 5 days in past
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: currentDate), equals(1));
    });

    test('day 0 (registration day) is Week 1', () {
      final regDate = DateTime(2026, 1, 1);
      final currentDate = DateTime(2026, 1, 1);
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: currentDate), equals(1));
    });

    test('day 6 (last day of first 7-day period) is still Week 1', () {
      final regDate = DateTime(2026, 1, 1);
      final currentDate = DateTime(2026, 1, 7); // 6 days difference
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: currentDate), equals(1));
    });

    test('day 7 (start of second 7-day period) is Week 2', () {
      final regDate = DateTime(2026, 1, 1);
      final currentDate = DateTime(2026, 1, 8); // 7 days difference
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: currentDate), equals(2));
    });

    test('day 13 is Week 2 and day 14 is Week 3', () {
      final regDate = DateTime(2026, 1, 1);
      final day13 = DateTime(2026, 1, 14); // 13 days
      final day14 = DateTime(2026, 1, 15); // 14 days
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: day13), equals(2));
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: day14), equals(3));
    });

    test('week progression across multiple weeks', () {
      final regDate = DateTime(2026, 1, 1);
      // 21 days -> (21 ~/ 7) + 1 = 4
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: DateTime(2026, 1, 22)), equals(4));
      // 70 days -> (70 ~/ 7) + 1 = 11
      expect(BossProgressionService.calculateWeekNumber(regDate, currentDate: DateTime(2026, 3, 12)), equals(11));
    });

    test('default currentDate parameter uses DateTime.now() without throwing', () {
      final regDate = DateTime.now();
      expect(BossProgressionService.calculateWeekNumber(regDate), equals(1));
    });
  });

  group('BossProgressionService - calculateBossMaxHp (110 + (week - 1) * 20)', () {
    test('week 1 base Boss Max HP is 110', () {
      expect(BossProgressionService.calculateBossMaxHp(1), equals(110));
    });

    test('week 2 Boss Max HP is 130', () {
      expect(BossProgressionService.calculateBossMaxHp(2), equals(130));
    });

    test('week 3 Boss Max HP is 150', () {
      expect(BossProgressionService.calculateBossMaxHp(3), equals(150));
    });

    test('week 5 Boss Max HP is 190', () {
      // 110 + (5 - 1) * 20 = 190
      expect(BossProgressionService.calculateBossMaxHp(5), equals(190));
    });

    test('week 10 Boss Max HP is 290', () {
      // 110 + (10 - 1) * 20 = 290
      expect(BossProgressionService.calculateBossMaxHp(10), equals(290));
    });

    test('edge case: week 0 or negative clamped to week 1 baseline (110 HP)', () {
      expect(BossProgressionService.calculateBossMaxHp(0), equals(110));
      expect(BossProgressionService.calculateBossMaxHp(-4), equals(110));
    });
  });

  group('BossProgressionService - calculateBossDamage (25 + (week - 1) * 10)', () {
    test('week 1 base Boss Damage is 25', () {
      expect(BossProgressionService.calculateBossDamage(1), equals(25));
    });

    test('week 2 Boss Damage is 35', () {
      expect(BossProgressionService.calculateBossDamage(2), equals(35));
    });

    test('week 3 Boss Damage is 45', () {
      expect(BossProgressionService.calculateBossDamage(3), equals(45));
    });

    test('week 5 Boss Damage is 65', () {
      // 25 + (5 - 1) * 10 = 65
      expect(BossProgressionService.calculateBossDamage(5), equals(65));
    });

    test('week 10 Boss Damage is 115', () {
      // 25 + (10 - 1) * 10 = 115
      expect(BossProgressionService.calculateBossDamage(10), equals(115));
    });

    test('edge case: week 0 or negative clamped to week 1 baseline (25 ATK)', () {
      expect(BossProgressionService.calculateBossDamage(0), equals(25));
      expect(BossProgressionService.calculateBossDamage(-2), equals(25));
    });
  });
}
