/// Elemento de la biblioteca de ejercicios. Sirve como plantilla al añadir ejercicios a una rutina.
class ExerciseTemplate {
  final int? id;
  final String name;
  final String muscleGroup;
  final bool isCompound;
  final bool isCustom;

  const ExerciseTemplate({
    this.id,
    required this.name,
    required this.muscleGroup,
    this.isCompound = false,
    this.isCustom = false,
  });

  int get suggestedRestSeconds => isCompound ? 180 : 90;

  ExerciseTemplate copyWith({
    int? id,
    String? name,
    String? muscleGroup,
    bool? isCompound,
    bool? isCustom,
  }) =>
      ExerciseTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        isCompound: isCompound ?? this.isCompound,
        isCustom: isCustom ?? this.isCustom,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExerciseTemplate && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'ExerciseTemplate($id, "$name", $muscleGroup)';
}
