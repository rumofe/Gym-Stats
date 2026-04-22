class SetLog {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final int setNumber;
  final double weightKg;
  final int repsDone;
  final int? rir;
  final bool completed;
  final String notes;

  const SetLog({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    this.weightKg = 0,
    this.repsDone = 0,
    this.rir,
    this.completed = false,
    this.notes = '',
  });

  SetLog copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? setNumber,
    double? weightKg,
    int? repsDone,
    int? rir,
    bool? completed,
    String? notes,
  }) =>
      SetLog(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        exerciseId: exerciseId ?? this.exerciseId,
        setNumber: setNumber ?? this.setNumber,
        weightKg: weightKg ?? this.weightKg,
        repsDone: repsDone ?? this.repsDone,
        rir: rir ?? this.rir,
        completed: completed ?? this.completed,
        notes: notes ?? this.notes,
      );

  @override
  bool operator ==(Object other) => identical(this, other) || other is SetLog && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() =>
      'SetLog(ex=$exerciseId, set=$setNumber, ${weightKg}kg×$repsDone)';
}
