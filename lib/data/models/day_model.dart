import '../../domain/entities/day.dart';
import '../../core/constants/db_constants.dart';
import 'exercise_model.dart';

class DayModel extends Day {
  const DayModel({
    super.id,
    required super.routineId,
    required super.name,
    super.orderIndex,
    super.exercises,
  });

  factory DayModel.fromMap(Map<String, dynamic> map,
      {List<ExerciseModel> exercises = const []}) {
    return DayModel(
      id: map[DbConstants.colId] as int?,
      routineId: map[DbConstants.colDayRoutineId] as int,
      name: map[DbConstants.colDayName] as String,
      orderIndex: (map[DbConstants.colDayOrder] as int?) ?? 0,
      exercises: exercises,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colDayRoutineId: routineId,
        DbConstants.colDayName: name,
        DbConstants.colDayOrder: orderIndex,
      };

  factory DayModel.fromEntity(Day d) => DayModel(
        id: d.id,
        routineId: d.routineId,
        name: d.name,
        orderIndex: d.orderIndex,
        exercises: d.exercises,
      );
}
