import '../../domain/entities/routine.dart';
import '../../core/constants/db_constants.dart';
import 'day_model.dart';

class RoutineModel extends Routine {
  const RoutineModel({
    super.id,
    required super.name,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.days,
  });

  factory RoutineModel.fromMap(Map<String, dynamic> map,
      {List<DayModel> days = const []}) {
    return RoutineModel(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colRoutineName] as String,
      description: (map[DbConstants.colRoutineDescription] as String?) ?? '',
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[DbConstants.colRoutineUpdatedAt] as String),
      days: days,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colRoutineName: name,
        DbConstants.colRoutineDescription: description,
        DbConstants.colCreatedAt: createdAt.toIso8601String(),
        DbConstants.colRoutineUpdatedAt: updatedAt.toIso8601String(),
      };

  factory RoutineModel.fromEntity(Routine r) => RoutineModel(
        id: r.id,
        name: r.name,
        description: r.description,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        days: r.days,
      );
}
