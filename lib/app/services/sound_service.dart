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

  // Keeper palette (keeper.md §7) — assets land with the rest of the sound
  // set; the opt-in toggle and the try/catch keep silent failure the default.
  static Future<void> playChirp() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/keeper_chirp.ogg'));
    } catch (_) {}
  }

  static Future<void> playTrill() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/keeper_trill.ogg'));
    } catch (_) {}
  }

  static Future<void> playPurr() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/keeper_purr.ogg'));
    } catch (_) {}
  }

  static Future<void> playBoop() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/keeper_boop.ogg'));
    } catch (_) {}
  }

  static Future<void> playGiggle() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/keeper_giggle.ogg'));
    } catch (_) {}
  }

  static Future<void> playSigh() async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/keeper_sigh.ogg'));
    } catch (_) {}
  }
}
