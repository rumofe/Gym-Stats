import '../entities/reminder.dart';
import '../entities/notification_log.dart';

abstract interface class IReminderRepository {
  Future<List<Reminder>> getAllReminders();
  Future<Reminder?> getReminderById(int id);
  Future<int> insertReminder(Reminder reminder);
  Future<void> updateReminder(Reminder reminder);
  Future<void> toggleReminder(int id, bool isActive);
  Future<void> incrementPostpone(int id);
  Future<void> resetPostpone(int id);

  Future<List<NotificationLog>> getRecentLogs({int limit = 30});
  Future<int> insertLog(NotificationLog log);
  Future<void> updateLogInteraction(int logId, String interaction);
  Future<List<String>> getBlacklistedMessages();
}
