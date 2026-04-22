import '../../domain/entities/cardio_session_template.dart';
import '../../core/constants/db_constants.dart';

class CardioSessionTemplateModel extends CardioSessionTemplate {
  const CardioSessionTemplateModel({
    super.id,
    required super.weekId,
    required super.name,
    required super.type,
    super.estimatedDuration,
    super.description,
    super.completed,
  });

  factory CardioSessionTemplateModel.fromMap(Map<String, dynamic> map) {
    return CardioSessionTemplateModel(
      id: map[DbConstants.colId] as int?,
      weekId: map[DbConstants.colCstWeekId] as int,
      name: map[DbConstants.colCstName] as String,
      type: map[DbConstants.colCstType] as String,
      estimatedDuration: (map[DbConstants.colCstDuration] as int?) ?? 30,
      description: (map[DbConstants.colCstDesc] as String?) ?? '',
      completed: ((map[DbConstants.colCstCompleted] as int?) ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colCstWeekId: weekId,
        DbConstants.colCstName: name,
        DbConstants.colCstType: type,
        DbConstants.colCstDuration: estimatedDuration,
        DbConstants.colCstDesc: description,
        DbConstants.colCstCompleted: completed ? 1 : 0,
      };

  factory CardioSessionTemplateModel.fromEntity(CardioSessionTemplate t) =>
      CardioSessionTemplateModel(
        id: t.id,
        weekId: t.weekId,
        name: t.name,
        type: t.type,
        estimatedDuration: t.estimatedDuration,
        description: t.description,
        completed: t.completed,
      );
}
