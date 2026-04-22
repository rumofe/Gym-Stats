import 'cardio_session_template.dart';

class CardioWeek {
  final int? id;
  final int planId;
  final int weekNumber;
  final String objective;
  final int targetSessions;
  final List<CardioSessionTemplate> sessions;

  const CardioWeek({
    this.id,
    required this.planId,
    required this.weekNumber,
    this.objective = '',
    this.targetSessions = 3,
    this.sessions = const [],
  });

  int get completedSessions => sessions.where((s) => s.completed).length;
  bool get isComplete => completedSessions >= targetSessions;
  double get progressPercent =>
      targetSessions == 0 ? 0 : completedSessions / targetSessions;

  CardioWeek copyWith({
    int? id,
    int? planId,
    int? weekNumber,
    String? objective,
    int? targetSessions,
    List<CardioSessionTemplate>? sessions,
  }) =>
      CardioWeek(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        weekNumber: weekNumber ?? this.weekNumber,
        objective: objective ?? this.objective,
        targetSessions: targetSessions ?? this.targetSessions,
        sessions: sessions ?? this.sessions,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CardioWeek && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
