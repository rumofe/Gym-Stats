import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/set_log.dart';
import '../../domain/entities/exercise_swap.dart';
import '../../domain/repositories/i_workout_repository.dart';
import '../database/database_helper.dart';
import '../models/workout_session_model.dart';
import '../models/set_log_model.dart';

class WorkoutRepositoryImpl implements IWorkoutRepository {
  final DatabaseHelper _db;
  WorkoutRepositoryImpl(this._db);

  Future<Database> get _database => _db.database;

  // ── Sesiones ──────────────────────────────────────────────────────────────
  @override
  Future<WorkoutSession?> getSessionById(int id) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableWorkoutSessions,
        where: '${DbConstants.colId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return WorkoutSessionModel.fromMap(rows.first);
  }

  @override
  Future<WorkoutSession?> getSessionWithLogs(int id) async {
    final session = await getSessionById(id);
    if (session == null) return null;
    final logs = await getLogsForSession(id);
    return session.copyWith(setLogs: logs);
  }

  @override
  Future<List<WorkoutSession>> getSessionsForDay(int dayId,
      {int limit = 50}) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableWorkoutSessions,
        where: '${DbConstants.colSessDayId} = ?',
        whereArgs: [dayId],
        orderBy: '${DbConstants.colSessDate} DESC',
        limit: limit);
    return rows.map((r) => WorkoutSessionModel.fromMap(r)).toList();
  }

  @override
  Future<List<WorkoutSession>> getSessionsInRange(
      DateTime from, DateTime to) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableWorkoutSessions,
        where:
            '${DbConstants.colSessDate} >= ? AND ${DbConstants.colSessDate} <= ?',
        whereArgs: [
          AppDateUtils.toIso(from),
          AppDateUtils.toIso(to),
        ],
        orderBy: '${DbConstants.colSessDate} DESC');
    return rows.map((r) => WorkoutSessionModel.fromMap(r)).toList();
  }

  @override
  Future<List<WorkoutSession>> getRecentSessions({int limit = 30}) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableWorkoutSessions,
        orderBy: '${DbConstants.colSessDate} DESC', limit: limit);
    return rows.map((r) => WorkoutSessionModel.fromMap(r)).toList();
  }

  @override
  Future<int> insertSession(WorkoutSession session) async {
    final db = await _database;
    return db.insert(DbConstants.tableWorkoutSessions,
        WorkoutSessionModel.fromEntity(session).toMap());
  }

  @override
  Future<void> updateSession(WorkoutSession session) async {
    final db = await _database;
    await db.update(
        DbConstants.tableWorkoutSessions,
        WorkoutSessionModel.fromEntity(session).toMap(),
        where: '${DbConstants.colId} = ?',
        whereArgs: [session.id]);
  }

  @override
  Future<void> deleteSession(int id) async {
    final db = await _database;
    await db.delete(DbConstants.tableWorkoutSessions,
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  // ── Set logs ──────────────────────────────────────────────────────────────
  @override
  Future<List<SetLog>> getLogsForSession(int sessionId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableSetLogs,
        where: '${DbConstants.colSetSessionId} = ?',
        whereArgs: [sessionId],
        orderBy:
            '${DbConstants.colSetExerciseId} ASC, ${DbConstants.colSetNumber} ASC');
    return rows.map((r) => SetLogModel.fromMap(r)).toList();
  }

  @override
  Future<List<SetLog>> getLastLogsForExercise(int exerciseId,
      {int limit = 5}) async {
    final db = await _database;
    // Obtiene las sesiones más recientes para este ejercicio
    final rows = await db.rawQuery('''
      SELECT sl.* FROM ${DbConstants.tableSetLogs} sl
      JOIN ${DbConstants.tableWorkoutSessions} ws
        ON sl.${DbConstants.colSetSessionId} = ws.${DbConstants.colId}
      WHERE sl.${DbConstants.colSetExerciseId} = ?
        AND sl.${DbConstants.colSetCompleted} = 1
      ORDER BY ws.${DbConstants.colSessDate} DESC, sl.${DbConstants.colSetNumber} ASC
      LIMIT ?
    ''', [exerciseId, limit * 10]);
    return rows.map((r) => SetLogModel.fromMap(r)).toList();
  }

  @override
  Future<int> insertSetLog(SetLog log) async {
    final db = await _database;
    return db.insert(
        DbConstants.tableSetLogs, SetLogModel.fromEntity(log).toMap());
  }

  @override
  Future<void> updateSetLog(SetLog log) async {
    final db = await _database;
    await db.update(DbConstants.tableSetLogs,
        SetLogModel.fromEntity(log).toMap(),
        where: '${DbConstants.colId} = ?', whereArgs: [log.id]);
  }

  @override
  Future<void> deleteSetLog(int id) async {
    final db = await _database;
    await db.delete(DbConstants.tableSetLogs,
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  @override
  Future<void> upsertSetLogs(List<SetLog> logs) async {
    final db = await _database;
    await db.transaction((txn) async {
      for (final log in logs) {
        if (log.id == null) {
          await txn.insert(
              DbConstants.tableSetLogs, SetLogModel.fromEntity(log).toMap());
        } else {
          await txn.update(DbConstants.tableSetLogs,
              SetLogModel.fromEntity(log).toMap(),
              where: '${DbConstants.colId} = ?', whereArgs: [log.id]);
        }
      }
    });
  }

  // ── Exercise swaps ────────────────────────────────────────────────────────
  @override
  Future<List<ExerciseSwap>> getSwapsForSession(int sessionId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableExerciseSwaps,
        where: '${DbConstants.colSwapSessId} = ?', whereArgs: [sessionId]);
    return rows.map((r) => _swapFromMap(r)).toList();
  }

  @override
  Future<int> insertExerciseSwap(ExerciseSwap swap) async {
    final db = await _database;
    return db.insert(DbConstants.tableExerciseSwaps, {
      DbConstants.colSwapOrigId: swap.originalExerciseId,
      DbConstants.colSwapSubId: swap.substituteExerciseId,
      DbConstants.colSwapSessId: swap.sessionId,
      DbConstants.colSwapDate: swap.date.toIso8601String(),
      DbConstants.colSwapReason: swap.reason,
      DbConstants.colSwapPermanent: swap.isPermanent ? 1 : 0,
    });
  }

  // ── Estadísticas ──────────────────────────────────────────────────────────
  @override
  Future<SetLog?> getBestSetForExercise(int exerciseId) async {
    final db = await _database;
    // Mejor set = mayor peso; en empate, mayor número de reps
    final rows = await db.query(DbConstants.tableSetLogs,
        where: '${DbConstants.colSetExerciseId} = ? AND ${DbConstants.colSetCompleted} = 1',
        whereArgs: [exerciseId],
        orderBy:
            '${DbConstants.colSetWeight} DESC, ${DbConstants.colSetReps} DESC',
        limit: 1);
    if (rows.isEmpty) return null;
    return SetLogModel.fromMap(rows.first);
  }

  @override
  Future<int> countSessionsInWeek(DateTime date) async {
    final db = await _database;
    final monday = AppDateUtils.startOfWeek(date);
    final sunday = monday.add(const Duration(days: 6));
    final result = await db.rawQuery('''
      SELECT COUNT(*) as cnt FROM ${DbConstants.tableWorkoutSessions}
      WHERE ${DbConstants.colSessDate} >= ? AND ${DbConstants.colSessDate} <= ?
        AND ${DbConstants.colSessCompleted} = 1
    ''', [AppDateUtils.toIso(monday), AppDateUtils.toIso(sunday)]);
    return (result.first['cnt'] as int?) ?? 0;
  }

  @override
  Future<int> getCurrentStreak() async {
    final db = await _database;
    // Obtiene fechas distintas con sesión completada, ordenadas DESC
    final rows = await db.rawQuery('''
      SELECT DISTINCT substr(${DbConstants.colSessDate}, 1, 10) as day
      FROM ${DbConstants.tableWorkoutSessions}
      WHERE ${DbConstants.colSessCompleted} = 1
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
  ExerciseSwap _swapFromMap(Map<String, dynamic> m) => ExerciseSwap(
        id: m[DbConstants.colId] as int?,
        originalExerciseId: m[DbConstants.colSwapOrigId] as int,
        substituteExerciseId: m[DbConstants.colSwapSubId] as int,
        sessionId: m[DbConstants.colSwapSessId] as int?,
        date: DateTime.parse(m[DbConstants.colSwapDate] as String),
        reason: (m[DbConstants.colSwapReason] as String?) ?? '',
        isPermanent: ((m[DbConstants.colSwapPermanent] as int?) ?? 0) == 1,
      );
}
