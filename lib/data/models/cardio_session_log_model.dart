import '../../domain/entities/cardio_session_log.dart';
import '../../core/constants/db_constants.dart';

class CardioSessionLogModel extends CardioSessionLog {
  const CardioSessionLogModel({
    super.id,
    required super.templateId,
    required super.date,
    required super.realDuration,
    super.distance,
    super.avgHr,
    super.maxHr,
    super.speed,
    super.incline,
    super.feeling,
    super.notes,
  });

  factory CardioSessionLogModel.fromMap(Map<String, dynamic> map) {
    return CardioSessionLogModel(
      id: map[DbConstants.colId] as int?,
      templateId: map[DbConstants.colCslTemplateId] as int,
      date: DateTime.parse(map[DbConstants.colCslDate] as String),
      realDuration: map[DbConstants.colCslDuration] as int,
      distance: (map[DbConstants.colCslDistance] as num?)?.toDouble(),
      avgHr: map[DbConstants.colCslAvgHr] as int?,
      maxHr: map[DbConstants.colCslMaxHr] as int?,
      speed: (map[DbConstants.colCslSpeed] as num?)?.toDouble(),
      incline: (map[DbConstants.colCslIncline] as num?)?.toDouble(),
      feeling: map[DbConstants.colCslFeeling] as int?,
      notes: (map[DbConstants.colCslNotes] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colCslTemplateId: templateId,
        DbConstants.colCslDate: date.toIso8601String(),
        DbConstants.colCslDuration: realDuration,
        DbConstants.colCslDistance: distance,
        DbConstants.colCslAvgHr: avgHr,
        DbConstants.colCslMaxHr: maxHr,
        DbConstants.colCslSpeed: speed,
        DbConstants.colCslIncline: incline,
        DbConstants.colCslFeeling: feeling,
        DbConstants.colCslNotes: notes,
      };

  factory CardioSessionLogModel.fromEntity(CardioSessionLog l) =>
      CardioSessionLogModel(
        id: l.id,
        templateId: l.templateId,
        date: l.date,
        realDuration: l.realDuration,
        distance: l.distance,
        avgHr: l.avgHr,
        maxHr: l.maxHr,
        speed: l.speed,
        incline: l.incline,
        feeling: l.feeling,
        notes: l.notes,
      );
}
