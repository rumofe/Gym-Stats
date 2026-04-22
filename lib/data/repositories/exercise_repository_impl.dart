import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../../domain/entities/exercise_template.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../database/database_helper.dart';
import '../models/exercise_template_model.dart';

class ExerciseRepositoryImpl implements IExerciseRepository {
  final DatabaseHelper _db;
  ExerciseRepositoryImpl(this._db);

  Future<Database> get _database => _db.database;

  @override
  Future<List<ExerciseTemplate>> getAllTemplates() async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableExerciseLibrary,
        orderBy: '${DbConstants.colLibMuscle} ASC, ${DbConstants.colLibName} ASC');
    return rows.map((r) => ExerciseTemplateModel.fromMap(r)).toList();
  }

  @override
  Future<List<ExerciseTemplate>> getTemplatesByMuscle(
      String muscleGroup) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableExerciseLibrary,
        where: '${DbConstants.colLibMuscle} = ?',
        whereArgs: [muscleGroup],
        orderBy: '${DbConstants.colLibName} ASC');
    return rows.map((r) => ExerciseTemplateModel.fromMap(r)).toList();
  }

  @override
  Future<List<ExerciseTemplate>> searchTemplates(String query) async {
    final db = await _database;
    final rows = await db.query(DbConstants.tableExerciseLibrary,
        where: '${DbConstants.colLibName} LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: '${DbConstants.colLibMuscle} ASC, ${DbConstants.colLibName} ASC');
    return rows.map((r) => ExerciseTemplateModel.fromMap(r)).toList();
  }

  @override
  Future<int> insertTemplate(ExerciseTemplate template) async {
    final db = await _database;
    return db.insert(DbConstants.tableExerciseLibrary,
        ExerciseTemplateModel.fromEntity(template).toMap());
  }

  @override
  Future<void> updateTemplate(ExerciseTemplate template) async {
    final db = await _database;
    await db.update(DbConstants.tableExerciseLibrary,
        ExerciseTemplateModel.fromEntity(template).toMap(),
        where: '${DbConstants.colId} = ?', whereArgs: [template.id]);
  }

  @override
  Future<void> deleteTemplate(int id) async {
    final db = await _database;
    // Solo se pueden borrar ejercicios personalizados
    await db.delete(DbConstants.tableExerciseLibrary,
        where:
            '${DbConstants.colId} = ? AND ${DbConstants.colLibCustom} = 1',
        whereArgs: [id]);
  }
}
