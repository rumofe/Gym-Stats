class Exercise {
  final int? id;
  final int dayId;
  final String name;
  final String muscleGroup;
  final int targetSets;
  final int repRangeMin;
  final int repRangeMax;
  final int rirTarget;
  final String notes;
  final int orderIndex;
  final int restSeconds;
  final bool isCompound;
  final int? libraryId;

  const Exercise({
    this.id,
    required this.dayId,
    required this.name,
    required this.muscleGroup,
    this.targetSets = 3,
    this.repRangeMin = 8,
    this.repRangeMax = 12,
    this.rirTarget = 2,
    this.notes = '',
    this.orderIndex = 0,
    this.restSeconds = 90,
    this.isCompound = false,
    this.libraryId,
  });

  String get repRangeDisplay => '$repRangeMin-$repRangeMax';
  String get setsDisplay => '$targetSets×$repRangeDisplay RIR$rirTarget';

  Exercise copyWith({
    int? id,
    int? dayId,
    String? name,
    String? muscleGroup,
    int? targetSets,
    int? repRangeMin,
    int? repRangeMax,
    int? rirTarget,
    String? notes,
    int? orderIndex,
    int? restSeconds,
    bool? isCompound,
    int? libraryId,
  }) =>
      Exercise(
        id: id ?? this.id,
        dayId: dayId ?? this.dayId,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        targetSets: targetSets ?? this.targetSets,
        repRangeMin: repRangeMin ?? this.repRangeMin,
        repRangeMax: repRangeMax ?? this.repRangeMax,
        rirTarget: rirTarget ?? this.rirTarget,
        notes: notes ?? this.notes,
        orderIndex: orderIndex ?? this.orderIndex,
        restSeconds: restSeconds ?? this.restSeconds,
        isCompound: isCompound ?? this.isCompound,
        libraryId: libraryId ?? this.libraryId,
      );

  @override
  bool operator ==(Object other) => identical(this, other) || other is Exercise && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'Exercise($id, "$name")';
}
