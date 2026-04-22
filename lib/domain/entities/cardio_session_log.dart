class CardioSessionLog {
  final int? id;
  final int templateId;
  final DateTime date;
  final int realDuration; // minutos
  final double? distance; // km
  final int? avgHr;
  final int? maxHr;
  final double? speed; // km/h
  final double? incline; // %
  final int? feeling; // 1-5
  final String notes;

  const CardioSessionLog({
    this.id,
    required this.templateId,
    required this.date,
    required this.realDuration,
    this.distance,
    this.avgHr,
    this.maxHr,
    this.speed,
    this.incline,
    this.feeling,
    this.notes = '',
  });

  CardioSessionLog copyWith({
    int? id,
    int? templateId,
    DateTime? date,
    int? realDuration,
    double? distance,
    int? avgHr,
    int? maxHr,
    double? speed,
    double? incline,
    int? feeling,
    String? notes,
  }) =>
      CardioSessionLog(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        date: date ?? this.date,
        realDuration: realDuration ?? this.realDuration,
        distance: distance ?? this.distance,
        avgHr: avgHr ?? this.avgHr,
        maxHr: maxHr ?? this.maxHr,
        speed: speed ?? this.speed,
        incline: incline ?? this.incline,
        feeling: feeling ?? this.feeling,
        notes: notes ?? this.notes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CardioSessionLog && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
