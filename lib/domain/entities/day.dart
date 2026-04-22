import 'exercise.dart';

class Day {
  final int? id;
  final int routineId;
  final String name;
  final int orderIndex;
  final List<Exercise> exercises;

  const Day({
    this.id,
    required this.routineId,
    required this.name,
    this.orderIndex = 0,
    this.exercises = const [],
  });

  Day copyWith({
    int? id,
    int? routineId,
    String? name,
    int? orderIndex,
    List<Exercise>? exercises,
  }) =>
      Day(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        name: name ?? this.name,
        orderIndex: orderIndex ?? this.orderIndex,
        exercises: exercises ?? this.exercises,
      );

  @override
  bool operator ==(Object other) => identical(this, other) || other is Day && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'Day($id, "$name", ${exercises.length} ex)';
}
