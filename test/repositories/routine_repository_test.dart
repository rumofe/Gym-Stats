import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_tracker/data/database/database_helper.dart';
import 'package:workout_tracker/data/repositories/routine_repository_impl.dart';
import 'package:workout_tracker/domain/entities/day.dart';
import 'package:workout_tracker/domain/entities/exercise.dart';
import 'package:workout_tracker/domain/entities/routine.dart';

void main() {
  late RoutineRepositoryImpl repo;
  final now = DateTime.now();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.instance.deleteDatabase();
    repo = RoutineRepositoryImpl(DatabaseHelper.instance);
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.deleteDatabase();
  });

  Routine makeRoutine(String name) => Routine(
        name: name,
        description: 'Test',
        createdAt: now,
        updatedAt: now,
      );

  Day makeDay(int routineId, String name, int order) => Day(
        routineId: routineId,
        name: name,
        orderIndex: order,
      );

  Exercise makeExercise(int dayId, String name) => Exercise(
        dayId: dayId,
        name: name,
        muscleGroup: 'Pecho',
        targetSets: 3,
        repRangeMin: 8,
        repRangeMax: 12,
        rirTarget: 2,
        isCompound: true,
      );

  group('Rutinas CRUD', () {
    test('insertar y obtener rutina', () async {
      final id = await repo.insertRoutine(makeRoutine('Test Rutina'));
      final r = await repo.getRoutineById(id);
      expect(r, isNotNull);
      expect(r!.name, equals('Test Rutina'));
      expect(r.id, equals(id));
    });

    test('getAllRoutines devuelve todas', () async {
      await repo.insertRoutine(makeRoutine('A'));
      await repo.insertRoutine(makeRoutine('B'));
      final list = await repo.getAllRoutines();
      expect(list.length, equals(2));
    });

    test('updateRoutine actualiza el nombre', () async {
      final id = await repo.insertRoutine(makeRoutine('Original'));
      final r = await repo.getRoutineById(id);
      await repo.updateRoutine(r!.copyWith(name: 'Actualizada'));
      final updated = await repo.getRoutineById(id);
      expect(updated!.name, equals('Actualizada'));
    });

    test('deleteRoutine elimina la rutina', () async {
      final id = await repo.insertRoutine(makeRoutine('Para borrar'));
      await repo.deleteRoutine(id);
      final r = await repo.getRoutineById(id);
      expect(r, isNull);
    });

    test('deleteRoutine elimina en cascada días y ejercicios', () async {
      final rid = await repo.insertRoutine(makeRoutine('Con días'));
      final did = await repo.insertDay(makeDay(rid, 'Día 1', 0));
      await repo.insertExercise(makeExercise(did, 'Press banca'));
      await repo.deleteRoutine(rid);

      final days = await repo.getDaysForRoutine(rid);
      final exercises = await repo.getExercisesForDay(did);
      expect(days, isEmpty);
      expect(exercises, isEmpty);
    });
  });

  group('Días CRUD', () {
    late int routineId;

    setUp(() async {
      routineId = await repo.insertRoutine(makeRoutine('Rutina base'));
    });

    test('insertar y obtener días de una rutina', () async {
      await repo.insertDay(makeDay(routineId, 'Upper A', 0));
      await repo.insertDay(makeDay(routineId, 'Lower A', 1));
      final days = await repo.getDaysForRoutine(routineId);
      expect(days.length, equals(2));
      expect(days.first.name, equals('Upper A'));
    });

    test('reorderDays actualiza el orden', () async {
      final id1 = await repo.insertDay(makeDay(routineId, 'Día 1', 0));
      final id2 = await repo.insertDay(makeDay(routineId, 'Día 2', 1));
      await repo.reorderDays([
        (id: id1, order: 1),
        (id: id2, order: 0),
      ]);
      final days = await repo.getDaysForRoutine(routineId);
      expect(days.first.name, equals('Día 2'));
    });
  });

  group('Ejercicios CRUD', () {
    late int dayId;

    setUp(() async {
      final rid = await repo.insertRoutine(makeRoutine('R'));
      dayId = await repo.insertDay(makeDay(rid, 'D', 0));
    });

    test('insertar y obtener ejercicios de un día', () async {
      await repo.insertExercise(makeExercise(dayId, 'Sentadilla'));
      await repo.insertExercise(makeExercise(dayId, 'Peso muerto'));
      final exercises = await repo.getExercisesForDay(dayId);
      expect(exercises.length, equals(2));
    });

    test('getDayWithExercises carga ejercicios correctamente', () async {
      await repo.insertExercise(makeExercise(dayId, 'Press banca'));
      final day = await repo.getDayWithExercises(dayId);
      expect(day, isNotNull);
      expect(day!.exercises.length, equals(1));
      expect(day.exercises.first.name, equals('Press banca'));
    });

    test('updateExercise actualiza el nombre', () async {
      await repo.insertExercise(makeExercise(dayId, 'Original'));
      final exs = await repo.getExercisesForDay(dayId);
      await repo.updateExercise(exs.first.copyWith(name: 'Actualizado'));
      final updated = await repo.getExercisesForDay(dayId);
      expect(updated.first.name, equals('Actualizado'));
    });

    test('getRoutineWithDays carga árbol completo', () async {
      final rid = await repo.insertRoutine(makeRoutine('Rutina árbol'));
      final did = await repo.insertDay(makeDay(rid, 'Día X', 0));
      await repo.insertExercise(makeExercise(did, 'Curl'));
      final routine = await repo.getRoutineWithDays(rid);
      expect(routine, isNotNull);
      final day = routine!.days.firstWhere((d) => d.name == 'Día X');
      expect(day.exercises.length, equals(1));
    });
  });
}
