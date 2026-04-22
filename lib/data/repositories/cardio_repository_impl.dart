import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/cardio_plan.dart';
import '../../domain/entities/cardio_week.dart';
import '../../domain/entities/cardio_session_template.dart';
import '../../domain/entities/cardio_session_log.dart';
import '../../domain/repositories/i_cardio_repository.dart';
import '../database/database_helper.dart';
import '../models/cardio_plan_model.dart';
import '../models/cardio_week_model.dart';
import '../models/cardio_session_template_model.dart';
import '../models/cardio_session_log_model.dart';

class CardioRepositoryImpl implements ICardioRepository {
  final DatabaseHelper _db;
  CardioRepositoryImpl(this._db);

  Future<Database> get _database => _db.database;

  // ── Plan ──────────────────────────────────────────────────────────────────
  @override
  Future<CardioPlan?> getActivePlan() async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableCardioPlan,
        orderBy: '${DbConstants.colId} DESC', limit: 1);
    if (rows.isEmpty) return null;
    return CardioPlanModel.fromMap(rows.first);
  }

  @override
  Future<CardioPlan?> getPlanWithWeeks(int planId) async {
    final plan = await _getPlanById(planId);
    if (plan == null) return null;
    final weeks = await _loadWeeksWithSessions(planId);
    return plan.copyWith(weeks: weeks);
  }

  @override
  Future<int> insertPlan(CardioPlan plan) async {
    final db = await _database;
    return db.insert(DbConstants.tableCardioPlan,
        CardioPlanModel.fromEntity(plan).toMap());
  }

  @override
  Future<void> updatePlan(CardioPlan plan) async {
    final db = await _database;
    await db.update(DbConstants.tableCardioPlan,
        CardioPlanModel.fromEntity(plan).toMap(),
        where: '${DbConstants.colId} = ?', whereArgs: [plan.id]);
  }

  // ── Semanas ───────────────────────────────────────────────────────────────
  @override
  Future<List<CardioWeek>> getWeeksForPlan(int planId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableCardioWeeks,
        where: '${DbConstants.colWeekPlanId} = ?',
        whereArgs: [planId],
        orderBy: '${DbConstants.colWeekNumber} ASC');
    return rows.map((r) => CardioWeekModel.fromMap(r)).toList();
  }

  @override
  Future<CardioWeek?> getWeekWithSessions(int weekId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableCardioWeeks,
        where: '${DbConstants.colId} = ?', whereArgs: [weekId], limit: 1);
    if (rows.isEmpty) return null;
    final sessions = await getSessionsForWeek(weekId);
    return CardioWeekModel.fromMap(rows.first,
        sessions: sessions
            .map(CardioSessionTemplateModel.fromEntity)
            .toList());
  }

  // ── Plantillas de sesión ──────────────────────────────────────────────────
  @override
  Future<List<CardioSessionTemplate>> getSessionsForWeek(int weekId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableCardioSessionTemplates,
        where: '${DbConstants.colCstWeekId} = ?', whereArgs: [weekId]);
    return rows.map((r) => CardioSessionTemplateModel.fromMap(r)).toList();
  }

  @override
  Future<void> markSessionCompleted(int templateId, bool completed) async {
    final db = await _database;
    await db.update(DbConstants.tableCardioSessionTemplates,
        {DbConstants.colCstCompleted: completed ? 1 : 0},
        where: '${DbConstants.colId} = ?', whereArgs: [templateId]);
  }

  // ── Logs ──────────────────────────────────────────────────────────────────
  @override
  Future<List<CardioSessionLog>> getLogsForTemplate(int templateId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableCardioSessionLogs,
        where: '${DbConstants.colCslTemplateId} = ?',
        whereArgs: [templateId],
        orderBy: '${DbConstants.colCslDate} DESC');
    return rows.map((r) => CardioSessionLogModel.fromMap(r)).toList();
  }

  @override
  Future<List<CardioSessionLog>> getLogsInRange(
      DateTime from, DateTime to) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableCardioSessionLogs,
        where:
            '${DbConstants.colCslDate} >= ? AND ${DbConstants.colCslDate} <= ?',
        whereArgs: [AppDateUtils.toIso(from), AppDateUtils.toIso(to)],
        orderBy: '${DbConstants.colCslDate} DESC');
    return rows.map((r) => CardioSessionLogModel.fromMap(r)).toList();
  }

  @override
  Future<int> insertLog(CardioSessionLog log) async {
    final db = await _database;
    return db.insert(DbConstants.tableCardioSessionLogs,
        CardioSessionLogModel.fromEntity(log).toMap());
  }

  @override
  Future<void> updateLog(CardioSessionLog log) async {
    final db = await _database;
    await db.update(DbConstants.tableCardioSessionLogs,
        CardioSessionLogModel.fromEntity(log).toMap(),
        where: '${DbConstants.colId} = ?', whereArgs: [log.id]);
  }

  @override
  Future<void> deleteLog(int id) async {
    final db = await _database;
    await db.delete(DbConstants.tableCardioSessionLogs,
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  // ── Estadísticas ──────────────────────────────────────────────────────────
  @override
  Future<int> countSessionsInWeek(DateTime date) async {
    final db = await _database;
    final monday = AppDateUtils.startOfWeek(date);
    final sunday = monday.add(const Duration(days: 6));
    final result = await db.rawQuery('''
      SELECT COUNT(*) as cnt FROM ${DbConstants.tableCardioSessionLogs}
      WHERE ${DbConstants.colCslDate} >= ? AND ${DbConstants.colCslDate} <= ?
    ''', [AppDateUtils.toIso(monday), AppDateUtils.toIso(sunday)]);
    return (result.first['cnt'] as int?) ?? 0;
  }

  @override
  Future<int> getCurrentCardioStreak() async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT substr(${DbConstants.colCslDate}, 1, 10) as day
      FROM ${DbConstants.tableCardioSessionLogs}
      ORDER BY day DESC
    ''');
    if (rows.isEmpty) return 0;

    int streak = 0;
    DateTime cursor = AppDateUtils.today();
    for (final row in rows) {
      final d = AppDateUtils.fromIso(row['day'] as String);
      final diff = AppDateUtils.daysBetween(d, cursor);
      if (diff == 0 || diff == 1) {
        streak++;
        cursor = d;
      } else {
        break;
      }
    }
    return streak;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<CardioPlan?> _getPlanById(int id) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableCardioPlan,
        where: '${DbConstants.colId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return CardioPlanModel.fromMap(rows.first);
  }

  Future<List<CardioWeek>> _loadWeeksWithSessions(int planId) async {
    final weeks = await getWeeksForPlan(planId);
    final result = <CardioWeek>[];
    for (final week in weeks) {
      final sessions = await getSessionsForWeek(week.id!);
      result.add(week.copyWith(sessions: sessions));
    }
    return result;
  }
}
