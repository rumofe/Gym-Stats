class CardioSessionTemplate {
  final int? id;
  final int weekId;
  final String name;
  final String type; // AppConstants.cardio*
  final int estimatedDuration; // minutos
  final String description;
  final bool completed;

  const CardioSessionTemplate({
    this.id,
    required this.weekId,
    required this.name,
    required this.type,
    this.estimatedDuration = 30,
    this.description = '',
    this.completed = false,
  });

  CardioSessionTemplate copyWith({
    int? id,
    int? weekId,
    String? name,
    String? type,
    int? estimatedDuration,
    String? description,
    bool? completed,
  }) =>
      CardioSessionTemplate(
        id: id ?? this.id,
        weekId: weekId ?? this.weekId,
        name: name ?? this.name,
        type: type ?? this.type,
        estimatedDuration: estimatedDuration ?? this.estimatedDuration,
        description: description ?? this.description,
        completed: completed ?? this.completed,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CardioSessionTemplate && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
