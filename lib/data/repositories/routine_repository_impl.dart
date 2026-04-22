import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/day.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/i_routine_repository.dart';
import '../database/database_helper.dart';
import '../models/routine_model.dart';
import '../models/day_model.dart';
import '../models/exercise_model.dart';

class RoutineRepositoryImpl implements IRoutineRepository {
  final DatabaseHelper _db;
  RoutineRepositoryImpl(this._db);

  Future<Database> get _database => _db.database;

  // ── Rutinas ───────────────────────────────────────────────────────────────
  @override
  Future<List<Routine>> getAllRoutines() async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableRoutines,
        orderBy: '${DbConstants.colCreatedAt} ASC');
    return rows.map((r) => RoutineModel.fromMap(r)).toList();
  }

  @override
  Future<Routine?> getRoutineById(int id) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableRoutines,
        where: '${DbConstants.colId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return RoutineModel.fromMap(rows.first);
  }

  @override
  Future<Routine?> getRoutineWithDays(int id) async {
    final routine = await getRoutineById(id);
    if (routine == null) return null;
    final days = await _loadDaysWithExercises(id);
    return routine.copyWith(days: days);
  }

  @override
  Future<int> insertRoutine(Routine routine) async {
    final db = await _database;
    return db.insert(DbConstants.tableRoutines,
        RoutineModel.fromEntity(routine).toMap());
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    final db = await _database;
    final map = RoutineModel.fromEntity(routine).toMap()
      ..[DbConstants.colRoutineUpdatedAt] = DateTime.now().toIso8601String();
    await db.update(DbConstants.tableRoutines, map,
        where: '${DbConstants.colId} = ?', whereArgs: [routine.id]);
  }

  @override
  Future<void> deleteRoutine(int id) async {
    final db = await _database;
    await db.delete(DbConstants.tableRoutines,
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  // ── Días ──────────────────────────────────────────────────────────────────
  @override
  Future<List<Day>> getDaysForRoutine(int routineId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableDays,
        where: '${DbConstants.colDayRoutineId} = ?',
        whereArgs: [routineId],
        orderBy: '${DbConstants.colDayOrder} ASC');
    return rows.map((r) => DayModel.fromMap(r)).toList();
  }

  @override
  Future<Day?> getDayWithExercises(int dayId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableDays,
        where: '${DbConstants.colId} = ?', whereArgs: [dayId], limit: 1);
    if (rows.isEmpty) return null;
    final exercises = await getExercisesForDay(dayId);
    return DayModel.fromMap(rows.first,
        exercises: exercises.map(ExerciseModel.fromEntity).toList());
  }

  @override
  Future<int> insertDay(Day day) async {
    final db = await _database;
    return db.insert(
        DbConstants.tableDays, DayModel.fromEntity(day).toMap());
  }

  @override
  Future<void> updateDay(Day day) async {
    final db = await _database;
    await db.update(DbConstants.tableDays, DayModel.fromEntity(day).toMap(),
        where: '${DbConstants.colId} = ?', whereArgs: [day.id]);
  }

  @override
  Future<void> deleteDay(int id) async {
    final db = await _database;
    await db.delete(DbConstants.tableDays,
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  @override
  Future<void> reorderDays(List<({int id, int order})> updates) async {
    final db = await _database;
    await db.transaction((txn) async {
      for (final u in updates) {
        await txn.update(DbConstants.tableDays,
            {DbConstants.colDayOrder: u.order},
            where: '${DbConstants.colId} = ?', whereArgs: [u.id]);
      }
    });
  }

  // ── Ejercicios ────────────────────────────────────────────────────────────
  @override
  Future<List<Exercise>> getExercisesForDay(int dayId) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableExercises,
        where: '${DbConstants.colExDayId} = ?',
        whereArgs: [dayId],
        orderBy: '${DbConstants.colExOrder} ASC');
    return rows.map((r) => ExerciseModel.fromMap(r)).toList();
  }

  @override
  Future<int> insertExercise(Exercise exercise) async {
    final db = await _database;
    return db.insert(DbConstants.tableExercises,
        ExerciseModel.fromEntity(exercise).toMap());
  }

  @override
  Future<void> updateExercise(Exercise exercise) async {
    final db = await _database;
    await db.update(DbConstants.tableExercises,
        ExerciseModel.fromEntity(exercise).toMap(),
        where: '${DbConstants.colId} = ?', whereArgs: [exercise.id]);
  }

  @override
  Future<void> deleteExercise(int id) async {
    final db = await _database;
    await db.delete(DbConstants.tableExercises,
        where: '${DbConstants.colId} = ?', whereArgs: [id]);
  }

  @override
  Future<void> reorderExercises(List<({int id, int order})> updates) async {
    final db = await _database;
    await db.transaction((txn) async {
      for (final u in updates) {
        await txn.update(DbConstants.tableExercises,
            {DbConstants.colExOrder: u.order},
            where: '${DbConstants.colId} = ?', whereArgs: [u.id]);
      }
    });
  }

  // ── Helpers privados ──────────────────────────────────────────────────────
  Future<List<Day>> _loadDaysWithExercises(int routineId) async {
    final days = await getDaysForRoutine(routineId);
    final result = <Day>[];
    for (final day in days) {
      final exercises = await getExercisesForDay(day.id!);
      result.add(day.copyWith(exercises: exercises));
    }
    return result;
  }
}
