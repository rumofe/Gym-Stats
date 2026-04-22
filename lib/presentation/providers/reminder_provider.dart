import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notifications/notification_service.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/notification_log.dart';
import '../../domain/repositories/i_reminder_repository.dart';
import 'providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ReminderState {
  final List<Reminder> reminders;
  final List<NotificationLog> recentLogs;

  const ReminderState({
    this.reminders = const [],
    this.recentLogs = const [],
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    List<NotificationLog>? recentLogs,
  }) =>
      ReminderState(
        reminders: reminders ?? this.reminders,
        recentLogs: recentLogs ?? this.recentLogs,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ReminderNotifier extends AsyncNotifier<ReminderState> {
  IReminderRepository get _repo => ref.read(reminderRepositoryProvider);
  NotificationService get _notif => NotificationService.instance;

  @override
  Future<ReminderState> build() => _load();

  Future<ReminderState> _load() async {
    final reminders = await _repo.getAllReminders();
    final logs = await _repo.getRecentLogs(limit: 40);
    return ReminderState(reminders: reminders, recentLogs: logs);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> toggle(int id, bool isActive) async {
    await _repo.toggleReminder(id, isActive);
    final reminder = await _repo.getReminderById(id);
    if (reminder != null) {
      final blacklist = await _repo.getBlacklistedMessages();
      if (isActive) {
        await _notif.scheduleReminder(reminder, blacklist: blacklist);
      } else {
        await _notif.cancelReminder(id);
      }
    }
    await refresh();
  }

  Future<void> updateReminder(Reminder updated) async {
    await _repo.updateReminder(updated);
    final blacklist = await _repo.getBlacklistedMessages();
    if (updated.isActive) {
      await _notif.scheduleReminder(updated, blacklist: blacklist);
    } else {
      await _notif.cancelReminder(updated.id!);
    }
    await refresh();
  }

  Future<void> addReminder(Reminder reminder) async {
    final id = await _repo.insertReminder(reminder);
    final saved = reminder.copyWith(id: id);
    final blacklist = await _repo.getBlacklistedMessages();
    if (saved.isActive) {
      await _notif.scheduleReminder(saved, blacklist: blacklist);
    }
    await refresh();
  }

  Future<void> scheduleAll() async {
    final reminders = await _repo.getAllReminders();
    final blacklist = await _repo.getBlacklistedMessages();
    for (final r in reminders) {
      await _notif.scheduleReminder(r, blacklist: blacklist);
    }
  }

  Future<void> blacklistMessage(NotificationLog log) async {
    await _repo.updateLogInteraction(
        log.id!, NotificationLog.interactionBlacklist);
    await scheduleAll(); // Reschedule to avoid blacklisted messages
    await refresh();
  }

  Future<void> markFavorite(NotificationLog log) async {
    await _repo.updateLogInteraction(
        log.id!, NotificationLog.interactionFavorite);
    await refresh();
  }
}

final reminderProvider =
    AsyncNotifierProvider<ReminderNotifier, ReminderState>(
        ReminderNotifier.new);
