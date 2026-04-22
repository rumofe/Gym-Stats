class ExerciseSwap {
  final int? id;
  final int originalExerciseId;
  final int substituteExerciseId;
  final int? sessionId;
  final DateTime date;
  final String reason;
  final bool isPermanent;

  const ExerciseSwap({
    this.id,
    required this.originalExerciseId,
    required this.substituteExerciseId,
    this.sessionId,
    required this.date,
    this.reason = '',
    this.isPermanent = false,
  });

  ExerciseSwap copyWith({
    int? id,
    int? originalExerciseId,
    int? substituteExerciseId,
    int? sessionId,
    DateTime? date,
    String? reason,
    bool? isPermanent,
  }) =>
      ExerciseSwap(
        id: id ?? this.id,
        originalExerciseId: originalExerciseId ?? this.originalExerciseId,
        substituteExerciseId: substituteExerciseId ?? this.substituteExerciseId,
        sessionId: sessionId ?? this.sessionId,
        date: date ?? this.date,
        reason: reason ?? this.reason,
        isPermanent: isPermanent ?? this.isPermanent,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExerciseSwap && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
