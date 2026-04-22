import '../../domain/entities/cardio_plan.dart';
import '../../core/constants/db_constants.dart';
import 'cardio_week_model.dart';

class CardioPlanModel extends CardioPlan {
  const CardioPlanModel({
    super.id,
    required super.name,
    super.description,
    required super.startDate,
    super.currentWeek,
    super.weeks,
  });

  factory CardioPlanModel.fromMap(Map<String, dynamic> map,
      {List<CardioWeekModel> weeks = const []}) {
    return CardioPlanModel(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colPlanName] as String,
      description: (map[DbConstants.colPlanDescription] as String?) ?? '',
      startDate: DateTime.parse(map[DbConstants.colPlanStartDate] as String),
      currentWeek: (map[DbConstants.colPlanCurrentWeek] as int?) ?? 1,
      weeks: weeks,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colPlanName: name,
        DbConstants.colPlanDescription: description,
        DbConstants.colPlanStartDate: startDate.toIso8601String(),
        DbConstants.colPlanCurrentWeek: currentWeek,
      };

  factory CardioPlanModel.fromEntity(CardioPlan p) => CardioPlanModel(
        id: p.id,
        name: p.name,
        description: p.description,
        startDate: p.startDate,
        currentWeek: p.currentWeek,
        weeks: p.weeks,
      );
}
