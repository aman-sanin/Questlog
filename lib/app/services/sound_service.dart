import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool soundEnabled = false;

  static Future<void> playCheck() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/check.ogg'));
    } catch (_) {}
  }

  static Future<void> playLevelUp() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/level_up.ogg'));
    } catch (_) {}
  }

  static Future<void> playUnlock() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/unlock.ogg'));
    } catch (_) {}
  }
}
