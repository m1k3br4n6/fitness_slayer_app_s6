import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _sfxPlayerAttack = AudioPlayer();
  static final AudioPlayer _sfxPlayerOrcAttack = AudioPlayer();
  static final AudioPlayer _sfxCommonSounds = AudioPlayer();

  static Future<void> playSwordSwing(int durationMs) async {
    try {
      // repeat sound until round ends
      await _sfxPlayerAttack.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayerAttack.play(AssetSource('sounds/knight_attack.wav'));
      await Future.delayed(Duration(milliseconds: durationMs));

    } finally {
      // stop when time is out
      await _sfxPlayerAttack.stop();
    }
  }

  static Future<void> playMageAtk(int durationMs) async {
    try {
      // repeat sound until round ends
      await _sfxPlayerAttack.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayerAttack.play(AssetSource('sounds/mage_attack.wav'));
      await Future.delayed(Duration(milliseconds: durationMs));

    } finally {
      // stop when time is out
      await _sfxPlayerAttack.stop();
    }
  }

  static Future<void> playOrcSwing(int durationMs) async {
    try {
      // repeat sound until round ends
      await _sfxPlayerOrcAttack.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayerOrcAttack.play(AssetSource('sounds/orc_attack.wav'));
      await Future.delayed(Duration(milliseconds: durationMs));

    } finally {
      // stop when time is out
      await _sfxPlayerOrcAttack.stop();
    }
  }

  static Future<void> playDeath(int durationMs) async {
    try {
      // repeat sound until round ends
      await _sfxCommonSounds.setReleaseMode(ReleaseMode.loop);
      await _sfxCommonSounds.play(AssetSource('sounds/death.wav'));
      await Future.delayed(Duration(milliseconds: durationMs));

    } finally {
      // stop when time is out
      await _sfxCommonSounds.stop();
    }
  }

  static Future<void> stopAll() async {
    await _sfxPlayerAttack.stop();
    await _sfxPlayerOrcAttack.stop();
  }
}
