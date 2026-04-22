import 'set_log.dart';

class WorkoutSession {
  final int? id;
  final int dayId;
  final DateTime date;
  final int? durationSeconds;
  final String notes;
  final int? feeling; // 1-5
  final bool completed;
  final List<SetLog> setLogs;

  const WorkoutSession({
    this.id,
    required this.dayId,
    required this.date,
    this.durationSeconds,
    this.notes = '',
    this.feeling,
    this.completed = false,
    this.setLogs = const [],
  });

  WorkoutSession copyWith({
    int? id,
    int? dayId,
    DateTime? date,
    int? durationSeconds,
    String? notes,
    int? feeling,
    bool? completed,
    List<SetLog>? setLogs,
  }) =>
      WorkoutSession(
        id: id ?? this.id,
        dayId: dayId ?? this.dayId,
        date: date ?? this.date,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        notes: notes ?? this.notes,
        feeling: feeling ?? this.feeling,
        completed: completed ?? this.completed,
        setLogs: setLogs ?? this.setLogs,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkoutSession && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'WorkoutSession($id, $date, dayId=$dayId)';
}
