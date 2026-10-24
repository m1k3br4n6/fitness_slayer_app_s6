import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:fitness_slayer_01/services/boss_progression_service.dart';

import 'audio_service.dart';

// Current phase of the combat state machine, enum allows the UI to know which character is currently active
enum BattlePhase {
  idle,
  slayerAttacking,
  bossAttacking,
  victory,
  defeat,
}

// Combat log event entry
class CombatLogEntry {
  final String message;
  final BattlePhase phase;

  CombatLogEntry({
    required this.message,
    required this.phase,
  });
}

// state management service to automatically notify listening UI widgets
// whenever combat stats, turns, or status messages update
class BossBattleService extends ChangeNotifier {
  bool _isDisposed = false;

  // CHARACTER STATS initialized from BossProgressionService
  String currentEquipment = 'knight';
  String slayerName = 'SLAYER';
  int slayerHp = BossProgressionService.slayerBaseHp;
  int slayerMaxHp = BossProgressionService.slayerBaseHp;
  int slayerDamage = BossProgressionService.slayerBaseDamage;

  String bossName = 'NOSFERATU ZODD';
  int bossHp = BossProgressionService.bossBaseHp;
  int bossMaxHp = BossProgressionService.bossBaseHp;
  int bossDamage = BossProgressionService.bossBaseDamage;

  // BATTLE STATE
  BattlePhase phase = BattlePhase.idle;
  String currentMessage = 'Tap START BATTLE to begin combat!';

  final List<CombatLogEntry> combatLogs = [];

  bool get isBattleActive =>
      phase == BattlePhase.slayerAttacking || phase == BattlePhase.bossAttacking;

  bool get isFinished => phase == BattlePhase.victory || phase == BattlePhase.defeat;

  // Randomly chooses boss to fight
  final String _bossType = Random().nextBool() ? 'orc_boss' : 'skeleton_boss';

  // Returns sprite sheet name for Boss based on combat phase
  String get bossSpriteName {
    if (phase == BattlePhase.bossAttacking) {
      return 'attack/${_bossType}_attack_spritesheet';
    }
    return 'idle/${_bossType}_idle_spritesheet';
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void updateProgressionStats({
    required int slayerLevel,
    required int weekNumber,
    String? slayerNameInput,
  }) {
    if (slayerNameInput != null && slayerNameInput.trim().isNotEmpty) {
      slayerName = slayerNameInput.trim();
    }

    slayerMaxHp = BossProgressionService.calculateSlayerMaxHp(slayerLevel);
    slayerDamage = BossProgressionService.calculateSlayerDamage(slayerLevel);

    bossMaxHp = BossProgressionService.calculateBossMaxHp(weekNumber);
    bossDamage = BossProgressionService.calculateBossDamage(weekNumber);

    if (!isBattleActive) {
      slayerHp = slayerMaxHp;
      bossHp = bossMaxHp;
    }

    notifyListeners();
  }

  // INITIALIZATION & RESET

  // Resets character health bars and returns the state machine to idle.
  void resetBattle() {
    slayerHp = slayerMaxHp;
    bossHp = bossMaxHp;
    phase = BattlePhase.idle;
    currentMessage = 'Tap START BATTLE to begin combat!';
    combatLogs.clear();
    notifyListeners();
  }


  // COMBAT SCRIPT

  Future<void> startBattleScript(String equippedClass) async {
    if (isBattleActive || _isDisposed) return;

    //Reset health bars to full when starting a new fight
    currentEquipment = equippedClass;
    slayerHp = slayerMaxHp;
    bossHp = bossMaxHp;
    combatLogs.clear();

    //start message
    _addLog('The battle between $slayerName and $bossName begins!', BattlePhase.idle);
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Combat loop continues until either character reaches 0 HP
    while (slayerHp > 0 && bossHp > 0 && !_isDisposed) {

      // SLAYER TURN
      phase = BattlePhase.slayerAttacking;
      currentMessage = '$slayerName prepares to strike $bossName!';
      notifyListeners();
      if (equippedClass == "Knight") {SoundService.playSwordSwing(2400);}
      if (equippedClass == "Mage") {SoundService.playMageAtk(2400);}


      // Pause for 800ms so the user sees Slayer is attacking
      await Future.delayed(const Duration(milliseconds: 800));

      if (phase != BattlePhase.slayerAttacking || _isDisposed) return;

      // SLAYER attack
      bossHp = (bossHp - slayerDamage).clamp(0, bossMaxHp);
      _addLog('$slayerName strikes $bossName for $slayerDamage damage!', phase);
      notifyListeners(); // UI updates Boss health bar downward

      // Check if Boss was slain
      if (bossHp <= 0) {
        phase = BattlePhase.victory;
        _addLog('VICTORY! $bossName has been slain!', phase);
        SoundService.stopAll();
        SoundService.playDeath(1000);
        notifyListeners();
        return; // End combat script on victory
      }

      // 2 second rest before boss turn
      await Future.delayed(const Duration(milliseconds: 1200));

      if (phase != BattlePhase.slayerAttacking || _isDisposed) return;

      // BOSS TURN
      phase = BattlePhase.bossAttacking;
      currentMessage = '$bossName prepares to counterattack $slayerName!';
      notifyListeners();
      SoundService.playOrcSwing(2400);

      // Pause for 800ms so the user sees Boss is attacking
      await Future.delayed(const Duration(milliseconds: 800));

      if (phase != BattlePhase.bossAttacking || _isDisposed) return;

      // BOSS attack
      slayerHp = (slayerHp - bossDamage).clamp(0, slayerMaxHp);
      _addLog('$bossName attacks $slayerName for $bossDamage damage!', phase);
      notifyListeners();

      // Check if Slayer was defeated
      if (slayerHp <= 0) {
        phase = BattlePhase.defeat;
        _addLog('DEFEAT! $slayerName has fallen in battle...', phase);
        SoundService.stopAll();
        SoundService.playDeath(1000);
        notifyListeners();
        return; // End combat script on defeat
      }

      // 2 second rest before slayer turn
      await Future.delayed(const Duration(milliseconds: 1200));

      if (phase != BattlePhase.bossAttacking || _isDisposed) return;
    }
  }

  // update current status message
  void _addLog(String message, BattlePhase currentPhase) {
    currentMessage = message;
    combatLogs.insert(
      0,
      CombatLogEntry(
        message: message,
        phase: currentPhase,
      ),
    );
  }
}
