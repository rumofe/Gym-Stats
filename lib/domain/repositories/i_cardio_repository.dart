import '../entities/cardio_plan.dart';
import '../entities/cardio_week.dart';
import '../entities/cardio_session_template.dart';
import '../entities/cardio_session_log.dart';

abstract interface class ICardioRepository {
  Future<CardioPlan?> getActivePlan();
  Future<CardioPlan?> getPlanWithWeeks(int planId);
  Future<int> insertPlan(CardioPlan plan);
  Future<void> updatePlan(CardioPlan plan);

  Future<List<CardioWeek>> getWeeksForPlan(int planId);
  Future<CardioWeek?> getWeekWithSessions(int weekId);

  Future<List<CardioSessionTemplate>> getSessionsForWeek(int weekId);
  Future<void> markSessionCompleted(int templateId, bool completed);

  Future<List<CardioSessionLog>> getLogsForTemplate(int templateId);
  Future<List<CardioSessionLog>> getLogsInRange(DateTime from, DateTime to);
  Future<int> insertLog(CardioSessionLog log);
  Future<void> updateLog(CardioSessionLog log);
  Future<void> deleteLog(int id);

  /// Sesiones de cardio completadas en la semana que contiene [date].
  Future<int> countSessionsInWeek(DateTime date);

  /// Días consecutivos con sesión de cardio hasta hoy.
  Future<int> getCurrentCardioStreak();
}
