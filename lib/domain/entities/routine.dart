import 'day.dart';

class Routine {
  final int? id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Day> days;

  const Routine({
    this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.days = const [],
  });

  Routine copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Day>? days,
  }) =>
      Routine(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        days: days ?? this.days,
      );

  @override
  bool operator ==(Object other) => identical(this, other) || other is Routine && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'Routine($id, "$name", ${days.length} days)';
}
