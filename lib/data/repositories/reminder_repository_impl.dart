import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/notification_log.dart';
import '../../domain/repositories/i_reminder_repository.dart';
import '../database/database_helper.dart';
import '../models/reminder_model.dart';
import '../models/notification_log_model.dart';

class ReminderRepositoryImpl implements IReminderRepository {
  final DatabaseHelper _db;
  ReminderRepositoryImpl(this._db);

  Future<Database> get _database => _db.database;

  // ── Recordatorios ─────────────────────────────────────────────────────────
  @override
  Future<List<Reminder>> getAllReminders() async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableReminders,
        orderBy: '${DbConstants.colId} ASC');
    return rows.map((r) => ReminderModel.fromMap(r)).toList();
  }

  @override
  Future<Reminder?> getReminderById(int id) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableReminders,
        where: '${DbConstants.colId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ReminderModel.fromMap(rows.first);
  }

  @override
  Future<int> insertReminder(Reminder reminder) async {
    final db = await _database;
    return db.insert(DbConstants.tableReminders,
        ReminderModel.fromEntity(reminder).toMap());
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final db = await _database;
    await db.update(DbConstants.tableReminders,
        ReminderModel.fromEntity(reminder).toMap(),
        where: '${DbConstants.colId} = ?', whereArgs: [reminder.id]);
  }

  @override
  Future<void> toggleReminder(int id, bool isActive) async {
    final db = await _database;
    await db.update(DbConstants.tableReminders,
        {DbConstants.colRemActive: isActive ? 1 : 0},
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  @override
  Future<void> incrementPostpone(int id) async {
    final db = await _database;
    await db.rawUpdate('''
      UPDATE ${DbConstants.tableReminders}
      SET ${DbConstants.colRemPostpone} = ${DbConstants.colRemPostpone} + 1
      WHERE ${DbConstants.colId} = ?
    ''', [id]);
  }

  @override
  Future<void> resetPostpone(int id) async {
    final db = await _database;
    await db.update(DbConstants.tableReminders,
        {DbConstants.colRemPostpone: 0},
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  // ── Logs de notificación ──────────────────────────────────────────────────
  @override
  Future<List<NotificationLog>> getRecentLogs({int limit = 30}) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableNotificationLogs,
        orderBy: '${DbConstants.colNlSentAt} DESC', limit: limit);
    return rows.map((r) => NotificationLogModel.fromMap(r)).toList();
  }

  @override
  Future<int> insertLog(NotificationLog log) async {
    final db = await _database;
    return db.insert(DbConstants.tableNotificationLogs,
        NotificationLogModel.fromEntity(log).toMap());
  }

  @override
  Future<void> updateLogInteraction(int logId, String interaction) async {
    final db = await _database;
    await db.update(DbConstants.tableNotificationLogs,
        {DbConstants.colNlInteract: interaction},
        where: '${DbConstants.colId} = ?', whereArgs: [logId]);
  }

  @override
  Future<List<String>> getBlacklistedMessages() async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableNotificationLogs,
        columns: [DbConstants.colNlMessage],
        where:
            '${DbConstants.colNlInteract} = ?',
        whereArgs: [NotificationLog.interactionBlacklist]);
    return rows.map((r) => r[DbConstants.colNlMessage] as String).toList();
  }
}
