import '../entities/routine.dart';
import '../entities/day.dart';
import '../entities/exercise.dart';

abstract interface class IRoutineRepository {
  Future<List<Routine>> getAllRoutines();
  Future<Routine?> getRoutineById(int id);
  /// Incluye días y ejercicios.
  Future<Routine?> getRoutineWithDays(int id);
  Future<int> insertRoutine(Routine routine);
  Future<void> updateRoutine(Routine routine);
  Future<void> deleteRoutine(int id);

  Future<List<Day>> getDaysForRoutine(int routineId);
  Future<Day?> getDayWithExercises(int dayId);
  Future<int> insertDay(Day day);
  Future<void> updateDay(Day day);
  Future<void> deleteDay(int id);
  Future<void> reorderDays(List<({int id, int order})> updates);

  Future<List<Exercise>> getExercisesForDay(int dayId);
  Future<int> insertExercise(Exercise exercise);
  Future<void> updateExercise(Exercise exercise);
  Future<void> deleteExercise(int id);
  Future<void> reorderExercises(List<({int id, int order})> updates);
}
