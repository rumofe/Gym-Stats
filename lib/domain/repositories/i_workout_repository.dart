import '../entities/workout_session.dart';
import '../entities/set_log.dart';
import '../entities/exercise_swap.dart';

abstract interface class IWorkoutRepository {
  Future<WorkoutSession?> getSessionById(int id);
  Future<WorkoutSession?> getSessionWithLogs(int id);
  Future<List<WorkoutSession>> getSessionsForDay(int dayId, {int limit = 50});
  Future<List<WorkoutSession>> getSessionsInRange(DateTime from, DateTime to);
  Future<List<WorkoutSession>> getRecentSessions({int limit = 30});
  Future<int> insertSession(WorkoutSession session);
  Future<void> updateSession(WorkoutSession session);
  Future<void> deleteSession(int id);

  Future<List<SetLog>> getLogsForSession(int sessionId);
  Future<List<SetLog>> getLastLogsForExercise(int exerciseId, {int limit = 5});
  Future<int> insertSetLog(SetLog log);
  Future<void> updateSetLog(SetLog log);
  Future<void> deleteSetLog(int id);
  Future<void> upsertSetLogs(List<SetLog> logs);

  Future<List<ExerciseSwap>> getSwapsForSession(int sessionId);
  Future<int> insertExerciseSwap(ExerciseSwap swap);

  /// Devuelve el mejor set_log (mayor peso×reps) para un ejercicio. Usado para detectar PRs.
  Future<SetLog?> getBestSetForExercise(int exerciseId);

  /// Sesiones completadas en la semana que contiene [date].
  Future<int> countSessionsInWeek(DateTime date);

  /// Racha actual: días consecutivos con sesión completada hasta hoy.
  Future<int> getCurrentStreak();
}
