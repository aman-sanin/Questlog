/// Single source of truth for every Keeper number (keeper.md §12).
/// Nothing in the widget or the engine hardcodes a motion/growth constant.
abstract final class KeeperTunables {
  // Idle — the entire motion budget (§2).
  static const int bobMs = 2400;
  static const double bobAmpDp = 2.5;
  static const int pulseMs = 4000;
  static const int pulseAnticipationMs = 2500;
  static const double pulseScale = 1.02;

  // Eye engine (§2, §12).
  static const int blinkMinMs = 3000;
  static const int blinkMaxMs = 7000;
  static const double doubleBlinkP = 0.10;
  static const int gazeMinMs = 3000;
  static const int gazeMaxMs = 8000;
  static const double gazeAmpU = 0.8; // idle gaze drift ±0.8u
  // Idle saccade amplitude scales per mood (§2/§5): attentive watches
  // furthest (×1.1 under anticipation), content drifts softly, resting
  // barely moves, quiescent wanders slowly.
  static const double gazeAmpAnticipationScale = 1.1;
  static const double gazeAmpContentScale = 0.55;
  static const double gazeAmpRestingScale = 0.35;
  static const double gazeAmpQuiescentScale = 0.5;
  static const int glanceTravelMs = 300;
  static const int glanceHoldMs = 500;
  static const double glanceClampU = 0.8; // glance clamp ±0.8u (x)
  static const double glanceClampVDU = 0.6; // glance clamp ±0.6u (y)
  static const double wide = 1.12;

  // Light menu & poses (§4, §6).
  static const int pingMs = 400;
  static const int gildFlashMs = 600;
  static const int gildHoldMs = 4000;
  static const int mouthPopMs = 150;
  static const int petWiggleMs = 400;

  // Growth (perfect-day thresholds) & the Legend capstone (§8).
  static const int growthWaking = 10;
  static const int growthAdorned = 30;
  static const int growthTrimmed = 100;
  static const int gildLevel = 30;

  // Sizes (§9).
  static const double faceSize = 28;
  static const double minProfileSize = 96;
  static const double maxProfileSize = 120;
  static const double zMoteMinSize = 64;
  static const double sparkleMinSize = 64;

  // Boop — tap recoil (§7)
  static const int boopMs = 250;
  static const int surpriseWideMs = 250;
  static const double boopSinkPx = 4; // recoil sink below rest
  static const double boopSquash = 0.96; // scaleY floor struck by the recoil

  // Tickle — rapid taps (§7)
  static const int tickleWindowMs = 800; // taps within this count as a burst
  static const int ticklesRequired = 3; // burst size that triggers a giggle
  static const int tickleMs = 800; // dizzy wobble duration
  static const double tickleWobbleAmpU = 0.6;

  // Grumpy — abuse of the tickle (§7, affect only)
  static const int grumpyTickles = 3; // tickle bursts inside the window
  static const int grumpyWindowMs = 12000;

  // Sad — abuse of the boop (§7, affect only)
  static const int boopSadCount = 4;
  static const int boopWindowMs = 5000;

  // Dwelling times for held poses (§7)
  static const int sadPoseMs = 1500;
  static const int grumpyPoseMs = 1400;
  static const int cheekyPoseMs = 1000;
  static const int shockedPoseMs = 600;
  static const int skepticalPoseMs = 900;
  static const int inLovePoseMs = 1800;

  // Affection (§7)
  static const double petAffectionPerStroke = 0.12;
  static const double petAffectionDecayPerSec = 0.02;
  static const double inLoveAffection = 0.8;
  static const int affectionDecayTickMs = 1000;

  // Pointer gaze spring (§7)
  static const double gazeSpringK = 0.15;
  static const double gazeFollowU = 0.8; // gaze tracks the pointer up to ±0.8u
  static const int skepticalHoverMs = 1500;
  static const int strokePurrMinMs = 350;
}