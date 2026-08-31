import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../data/db/database.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/model/models.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Deep link handling when tapped
      },
    );

    _initialized = true;
  }

  Future<bool?> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      return await androidImpl.requestNotificationsPermission();
    }
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      return await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
    }
    return true;
  }

  /// Reconciles desired notification set (digest + per-quest reminders)
  Future<void> reconcile({
    required ProfileData profile,
    required List<QuestData> activeQuests,
    required List<QuestEvaluation> evaluations,
    required LocalDate today,
  }) async {
    await initialize();

    // Cancel all previously scheduled notifications
    await _plugin.cancelAll();

    const androidDetails = AndroidNotificationDetails(
      'questlog_reminders',
      'Quest Reminders & Digest',
      channelDescription: 'Daily digest and quest reminder alarms',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    int notifId = 100;

    // 1. Daily Digest Notification (if enabled)
    if (profile.digestEnabled) {
      final digestMinute = profile.digestMinute;
      final hour = digestMinute ~/ 60;
      final minute = digestMinute % 60;

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final dueCount = evaluations.where((e) => e.isDueToday).length;

      try {
        await _plugin.zonedSchedule(
          id: notifId++,
          title: 'QuestLog · Daily Log',
          body: dueCount > 0
              ? '$dueCount quest${dueCount == 1 ? "" : "s"} scheduled for today.'
              : 'Your daily log is open.',
          scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails: notifDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {
        // Fallback for permission / exact alarm restrictions
      }
    }

    // 2. Per-quest Reminders (if scheduled today & not yet completed)
    for (final q in activeQuests) {
      if (q.reminderMinute == null) continue;

      final eval = evaluations.firstWhere(
        (e) => e.questId == q.id,
        orElse: () => QuestEvaluation(
          questId: q.id,
          title: q.title,
          rule: q.rule,
          targetType: TargetType.values[q.targetType],
          targetValue: q.targetValue,
          difficulty: Difficulty.values[q.difficulty],
          essential: q.essential,
          isDueToday: false,
          completedValue: 0,
          target: q.targetValue,
          progress: 0.0,
          isCompleted: false,
          streak: 0,
          visualState: QuestVisual.pending,
          metaDescription: '',
        ),
      );

      // Only schedule if due today and not yet completed
      if (!eval.isDueToday || eval.isCompleted) continue;

      final hour = q.reminderMinute! ~/ 60;
      final minute = q.reminderMinute! % 60;

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isAfter(now)) {
        try {
          await _plugin.zonedSchedule(
            id: notifId++,
            title: q.title,
            body: q.essential ? 'Essential daily quest' : 'Scheduled reminder',
            scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
            notificationDetails: notifDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } catch (_) {}
      }
    }
  }
}
