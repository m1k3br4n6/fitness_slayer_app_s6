import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AmbientBattleService {
  static final AudioPlayer _attackerPlayer = AudioPlayer();
  static final AudioPlayer _hurtPlayer = AudioPlayer();
  static final Random _random = Random();
  static bool _isRunning = false;

  // Cache the equipment so pause/resume buttons don't need to re-pass it
  static String _currentClass = 'knight';

  // Your general combat sounds assigned to the monsters
  static final List<String> _enemyAttacks = [
    'sounds/workout_fighting_sounds/jump.wav',
    'sounds/workout_fighting_sounds/punch.wav',
    'sounds/workout_fighting_sounds/punch2.wav',
    'sounds/workout_fighting_sounds/slap.wav',
    'sounds/workout_fighting_sounds/swipe.wav',
    'sounds/workout_fighting_sounds/squelching.wav',
  ];

  static void startAmbientCombat([String? equippedClass]) {
    if (equippedClass != null) {
      _currentClass = equippedClass;
    }
    if (_isRunning) return;
    _isRunning = true;
    _playRandomEvent();
  }

  static Future<void> _playRandomEvent() async {
    if (!_isRunning) return;

    bool isPlayerTurn = _random.nextBool();
    // Radom who attacks between enemy and player

    if (isPlayerTurn) {
      // PLAYER ATTACKS
      String playerAttackSound = _currentClass == 'Mage'
          ? 'sounds/mage_attack.wav'
          : 'sounds/knight_attack.wav';
      await _attackerPlayer.play(AssetSource(playerAttackSound));

      // random 50 50 if the monsters take damage
      if (_random.nextBool()) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_isRunning) {
            _hurtPlayer.play(AssetSource('sounds/workout_fighting_sounds/hurt.wav'));
          }
        });
      }
    } else {
      // ENEMY ATTACKS
      String enemyAttackSound = _enemyAttacks[_random.nextInt(_enemyAttacks.length)];
      await _attackerPlayer.play(AssetSource(enemyAttackSound));

      // random 50 50 if the player take damage
      if (_random.nextBool()) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_isRunning) {
            _hurtPlayer.play(AssetSource('sounds/workout_fighting_sounds/hurt.wav'));
          }
        });
      }
    }

    // Wait random between each attack
    int nextDelayMs = 1000 + _random.nextInt(1000);
    await Future.delayed(Duration(milliseconds: nextDelayMs));

    // Loop recursively
    if (_isRunning) {
      _playRandomEvent();
    }
  }

  static void stopAmbientCombat() {
    _isRunning = false;
    _attackerPlayer.stop();
    _hurtPlayer.stop();
  }
}