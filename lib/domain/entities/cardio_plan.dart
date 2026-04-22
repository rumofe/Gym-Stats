import 'cardio_week.dart';

class CardioPlan {
  final int? id;
  final String name;
  final String description;
  final DateTime startDate;
  final int currentWeek;
  final List<CardioWeek> weeks;

  const CardioPlan({
    this.id,
    required this.name,
    this.description = '',
    required this.startDate,
    this.currentWeek = 1,
    this.weeks = const [],
  });

  int get totalSessions =>
      weeks.fold(0, (acc, w) => acc + w.targetSessions);
  int get completedSessions =>
      weeks.fold(0, (acc, w) => acc + w.completedSessions);
  double get globalProgress =>
      totalSessions == 0 ? 0 : completedSessions / totalSessions;

  CardioPlan copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    int? currentWeek,
    List<CardioWeek>? weeks,
  }) =>
      CardioPlan(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        currentWeek: currentWeek ?? this.currentWeek,
        weeks: weeks ?? this.weeks,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CardioPlan && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
