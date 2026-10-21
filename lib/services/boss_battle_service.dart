import 'dart:async';
import 'package:flutter/foundation.dart';

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

  // CHARACTER STATS

  String slayerName = 'SLAYER';
  int slayerHp = 100;
  int slayerMaxHp = 100;
  int slayerDamage = 20;

  String bossName = 'NOSFERATU ZODD';
  int bossHp = 100;
  int bossMaxHp = 100;
  int bossDamage = 15;

  // BATTLE STATE
  BattlePhase phase = BattlePhase.idle;
  String currentMessage = 'Tap START BATTLE to begin combat!';

  final List<CombatLogEntry> combatLogs = [];

  bool get isBattleActive =>
      phase == BattlePhase.slayerAttacking || phase == BattlePhase.bossAttacking;

  bool get isFinished => phase == BattlePhase.victory || phase == BattlePhase.defeat;

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

  Future<void> startBattleScript() async {
    if (isBattleActive) return;

    //Reset health bars to full when starting a new fight
    slayerHp = slayerMaxHp;
    bossHp = bossMaxHp;
    combatLogs.clear();

    //start message
    _addLog('The battle between $slayerName and $bossName begins!', BattlePhase.idle);
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Combat loop continues until either character reaches 0 HP
    while (slayerHp > 0 && bossHp > 0) {

      // SLAYER TURN
      // TODO: Slayer attack sprite animation when phase becomes slayerAttacking
      phase = BattlePhase.slayerAttacking;
      currentMessage = '$slayerName prepares to strike $bossName!';
      notifyListeners();

      // Pause for 800ms so the user sees Slayer is attacking
      await Future.delayed(const Duration(milliseconds: 800));

      if (phase != BattlePhase.slayerAttacking) return;

      // SLAYER attack
      bossHp = (bossHp - slayerDamage).clamp(0, bossMaxHp);
      _addLog('$slayerName strikes $bossName for $slayerDamage damage!', phase);
      notifyListeners(); // UI updates Boss health bar downward

      // Check if Boss was slain
      if (bossHp <= 0) {
        phase = BattlePhase.victory;
        _addLog('VICTORY! $bossName has been slain!', phase);
        notifyListeners();
        return; // End combat script on victory
      }

      // 2 second rest before boss turn
      await Future.delayed(const Duration(milliseconds: 1200));

      if (phase != BattlePhase.slayerAttacking) return;

      // BOSS TURN
      // TODO: Boss attack sprite animation when phase becomes bossAttacking
      phase = BattlePhase.bossAttacking;
      currentMessage = '$bossName prepares to counterattack $slayerName!';
      notifyListeners();

      // Pause for 800ms so the user sees Boss is attacking
      await Future.delayed(const Duration(milliseconds: 800));

      if (phase != BattlePhase.bossAttacking) return;

      // BOSS attack
      slayerHp = (slayerHp - bossDamage).clamp(0, slayerMaxHp);
      _addLog('$bossName attacks $slayerName for $bossDamage damage!', phase);
      notifyListeners();

      // Check if Slayer was defeated
      if (slayerHp <= 0) {
        phase = BattlePhase.defeat;
        _addLog('DEFEAT! $slayerName has fallen in battle...', phase);
        notifyListeners();
        return; // End combat script on defeat
      }

      // 2 second rest before slayer turn
      await Future.delayed(const Duration(milliseconds: 1200));

      if (phase != BattlePhase.bossAttacking) return;
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
