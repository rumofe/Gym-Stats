import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../core/constants/app_constants.dart';
import '../../domain/entities/reminder.dart';
import 'message_pool.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    // Try to detect local timezone, fall back to UTC
    try {
      final localTz = tz.local;
      tz.setLocalLocation(localTz);
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;
    return granted;
  }

  // ── Schedule ──────────────────────────────────────────────────────────────

  /// Schedules one weekly notification per active day for [reminder].
  /// [blacklist] is a list of messages the user has blocked.
  Future<void> scheduleReminder(
    Reminder reminder, {
    List<String> blacklist = const [],
  }) async {
    await cancelReminder(reminder.id!);
    if (!reminder.isActive) return;

    final messages = MessagePool.getFiltered(
      reminder.type,
      // If postponed 3+ times, force sarcastic
      reminder.postponeCount >= 3
          ? AppConstants.personalitySarcastic
          : reminder.personality,
      blacklist,
    );

    final timeParts = reminder.scheduledTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      final bit = 1 << dayIndex; // Mon=1, Tue=2 ... Sun=64
      if (reminder.activeDaysBitmask & bit == 0) continue;

      final notifId = _notifId(reminder.id!, dayIndex);
      final message = messages[Random().nextInt(messages.length)];
      final title = _titleFor(reminder.type);

      final scheduledDate = _nextOccurrence(
        weekday: dayIndex + 1, // DateTime.monday=1
        hour: hour,
        minute: minute,
      );

      await _plugin.zonedSchedule(
        notifId,
        title,
        message,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_${reminder.type}',
            _channelName(reminder.type),
            channelDescription: 'Recordatorios de WorkoutTracker',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelReminder(int reminderId) async {
    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      await _plugin.cancel(_notifId(reminderId, dayIndex));
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _notifId(int reminderId, int dayIndex) =>
      AppConstants.notifBaseId + reminderId * 10 + dayIndex;

  tz.TZDateTime _nextOccurrence({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    var now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    // Advance to the target weekday
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _titleFor(String type) {
    switch (type) {
      case AppConstants.reminderGym:
        return '💪 WorkoutTracker';
      case AppConstants.reminderCardio:
        return '🏃 Cardio';
      case AppConstants.reminderWeigh:
        return '⚖️ Control de peso';
      default:
        return '🔥 WorkoutTracker';
    }
  }

  String _channelName(String type) {
    switch (type) {
      case AppConstants.reminderGym:
        return 'Gym reminders';
      case AppConstants.reminderCardio:
        return 'Cardio reminders';
      case AppConstants.reminderWeigh:
        return 'Weight reminders';
      default:
        return 'Motivational reminders';
    }
  }
}
