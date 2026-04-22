import '../../domain/entities/exercise_template.dart';
import '../../core/constants/db_constants.dart';

class ExerciseTemplateModel extends ExerciseTemplate {
  const ExerciseTemplateModel({
    super.id,
    required super.name,
    required super.muscleGroup,
    super.isCompound,
    super.isCustom,
  });

  factory ExerciseTemplateModel.fromMap(Map<String, dynamic> map) {
    return ExerciseTemplateModel(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colLibName] as String,
      muscleGroup: map[DbConstants.colLibMuscle] as String,
      isCompound: ((map[DbConstants.colLibCompound] as int?) ?? 0) == 1,
      isCustom: ((map[DbConstants.colLibCustom] as int?) ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colLibName: name,
        DbConstants.colLibMuscle: muscleGroup,
        DbConstants.colLibCompound: isCompound ? 1 : 0,
        DbConstants.colLibCustom: isCustom ? 1 : 0,
      };

  factory ExerciseTemplateModel.fromEntity(ExerciseTemplate t) =>
      ExerciseTemplateModel(
        id: t.id,
        name: t.name,
        muscleGroup: t.muscleGroup,
        isCompound: t.isCompound,
        isCustom: t.isCustom,
      );
}
