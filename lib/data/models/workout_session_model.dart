import '../../domain/entities/workout_session.dart';
import '../../core/constants/db_constants.dart';
import 'set_log_model.dart';

class WorkoutSessionModel extends WorkoutSession {
  const WorkoutSessionModel({
    super.id,
    required super.dayId,
    required super.date,
    super.durationSeconds,
    super.notes,
    super.feeling,
    super.completed,
    super.setLogs,
  });

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map,
      {List<SetLogModel> setLogs = const []}) {
    return WorkoutSessionModel(
      id: map[DbConstants.colId] as int?,
      dayId: map[DbConstants.colSessDayId] as int,
      date: DateTime.parse(map[DbConstants.colSessDate] as String),
      durationSeconds: map[DbConstants.colSessDuration] as int?,
      notes: (map[DbConstants.colSessNotes] as String?) ?? '',
      feeling: map[DbConstants.colSessFeeling] as int?,
      completed: ((map[DbConstants.colSessCompleted] as int?) ?? 0) == 1,
      setLogs: setLogs,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colSessDayId: dayId,
        DbConstants.colSessDate: date.toIso8601String(),
        DbConstants.colSessDuration: durationSeconds,
        DbConstants.colSessNotes: notes,
        DbConstants.colSessFeeling: feeling,
        DbConstants.colSessCompleted: completed ? 1 : 0,
      };

  factory WorkoutSessionModel.fromEntity(WorkoutSession s) =>
      WorkoutSessionModel(
        id: s.id,
        dayId: s.dayId,
        date: s.date,
        durationSeconds: s.durationSeconds,
        notes: s.notes,
        feeling: s.feeling,
        completed: s.completed,
        setLogs: s.setLogs,
      );
}
