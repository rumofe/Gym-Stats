import '../../domain/entities/exercise.dart';
import '../../core/constants/db_constants.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    super.id,
    required super.dayId,
    required super.name,
    required super.muscleGroup,
    super.targetSets,
    super.repRangeMin,
    super.repRangeMax,
    super.rirTarget,
    super.notes,
    super.orderIndex,
    super.restSeconds,
    super.isCompound,
    super.libraryId,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map[DbConstants.colId] as int?,
      dayId: map[DbConstants.colExDayId] as int,
      name: map[DbConstants.colExName] as String,
      muscleGroup: map[DbConstants.colExMuscle] as String,
      targetSets: (map[DbConstants.colExSets] as int?) ?? 3,
      repRangeMin: (map[DbConstants.colExRepMin] as int?) ?? 8,
      repRangeMax: (map[DbConstants.colExRepMax] as int?) ?? 12,
      rirTarget: (map[DbConstants.colExRir] as int?) ?? 2,
      notes: (map[DbConstants.colExNotes] as String?) ?? '',
      orderIndex: (map[DbConstants.colExOrder] as int?) ?? 0,
      restSeconds: (map[DbConstants.colExRest] as int?) ?? 90,
      isCompound: ((map[DbConstants.colExCompound] as int?) ?? 0) == 1,
      libraryId: map[DbConstants.colExLibraryId] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colExDayId: dayId,
        DbConstants.colExName: name,
        DbConstants.colExMuscle: muscleGroup,
        DbConstants.colExSets: targetSets,
        DbConstants.colExRepMin: repRangeMin,
        DbConstants.colExRepMax: repRangeMax,
        DbConstants.colExRir: rirTarget,
        DbConstants.colExNotes: notes,
        DbConstants.colExOrder: orderIndex,
        DbConstants.colExRest: restSeconds,
        DbConstants.colExCompound: isCompound ? 1 : 0,
        DbConstants.colExLibraryId: libraryId,
      };

  factory ExerciseModel.fromEntity(Exercise e) => ExerciseModel(
        id: e.id,
        dayId: e.dayId,
        name: e.name,
        muscleGroup: e.muscleGroup,
        targetSets: e.targetSets,
        repRangeMin: e.repRangeMin,
        repRangeMax: e.repRangeMax,
        rirTarget: e.rirTarget,
        notes: e.notes,
        orderIndex: e.orderIndex,
        restSeconds: e.restSeconds,
        isCompound: e.isCompound,
        libraryId: e.libraryId,
      );
}
