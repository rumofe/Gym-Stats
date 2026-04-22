import '../../domain/entities/set_log.dart';
import '../../core/constants/db_constants.dart';

class SetLogModel extends SetLog {
  const SetLogModel({
    super.id,
    required super.sessionId,
    required super.exerciseId,
    required super.setNumber,
    super.weightKg,
    super.repsDone,
    super.rir,
    super.completed,
    super.notes,
  });

  factory SetLogModel.fromMap(Map<String, dynamic> map) {
    return SetLogModel(
      id: map[DbConstants.colId] as int?,
      sessionId: map[DbConstants.colSetSessionId] as int,
      exerciseId: map[DbConstants.colSetExerciseId] as int,
      setNumber: map[DbConstants.colSetNumber] as int,
      weightKg: (map[DbConstants.colSetWeight] as num?)?.toDouble() ?? 0,
      repsDone: (map[DbConstants.colSetReps] as int?) ?? 0,
      rir: map[DbConstants.colSetRir] as int?,
      completed: ((map[DbConstants.colSetCompleted] as int?) ?? 0) == 1,
      notes: (map[DbConstants.colSetNotes] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colSetSessionId: sessionId,
        DbConstants.colSetExerciseId: exerciseId,
        DbConstants.colSetNumber: setNumber,
        DbConstants.colSetWeight: weightKg,
        DbConstants.colSetReps: repsDone,
        DbConstants.colSetRir: rir,
        DbConstants.colSetCompleted: completed ? 1 : 0,
        DbConstants.colSetNotes: notes,
      };

  factory SetLogModel.fromEntity(SetLog s) => SetLogModel(
        id: s.id,
        sessionId: s.sessionId,
        exerciseId: s.exerciseId,
        setNumber: s.setNumber,
        weightKg: s.weightKg,
        repsDone: s.repsDone,
        rir: s.rir,
        completed: s.completed,
        notes: s.notes,
      );
}
