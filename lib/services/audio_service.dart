import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _sfxPlayerKnightAttack = AudioPlayer();
  static final AudioPlayer _sfxPlayerOrcAttack = AudioPlayer();

  static Future<void> playSwordSwing(int durationMs) async {
    try {
      // repeat sound until round ends
      await _sfxPlayerKnightAttack.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayerKnightAttack.play(AssetSource('sounds/knight_attack.wav'));
      await Future.delayed(Duration(milliseconds: durationMs));

    } finally {
      // stop when time is out
      await _sfxPlayerKnightAttack.stop();
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

  static Future<void> stopAll() async {
    await _sfxPlayerKnightAttack.stop();
    await _sfxPlayerOrcAttack.stop();
  }
}
