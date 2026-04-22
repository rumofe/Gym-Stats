import '../../domain/entities/cardio_week.dart';
import '../../core/constants/db_constants.dart';
import 'cardio_session_template_model.dart';

class CardioWeekModel extends CardioWeek {
  const CardioWeekModel({
    super.id,
    required super.planId,
    required super.weekNumber,
    super.objective,
    super.targetSessions,
    super.sessions,
  });

  factory CardioWeekModel.fromMap(Map<String, dynamic> map,
      {List<CardioSessionTemplateModel> sessions = const []}) {
    return CardioWeekModel(
      id: map[DbConstants.colId] as int?,
      planId: map[DbConstants.colWeekPlanId] as int,
      weekNumber: map[DbConstants.colWeekNumber] as int,
      objective: (map[DbConstants.colWeekObjective] as String?) ?? '',
      targetSessions: (map[DbConstants.colWeekTargetSess] as int?) ?? 3,
      sessions: sessions,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colWeekPlanId: planId,
        DbConstants.colWeekNumber: weekNumber,
        DbConstants.colWeekObjective: objective,
        DbConstants.colWeekTargetSess: targetSessions,
      };

  factory CardioWeekModel.fromEntity(CardioWeek w) => CardioWeekModel(
        id: w.id,
        planId: w.planId,
        weekNumber: w.weekNumber,
        objective: w.objective,
        targetSessions: w.targetSessions,
        sessions: w.sessions,
      );
}
