import '../../domain/entities/notification_log.dart';
import '../../core/constants/db_constants.dart';

class NotificationLogModel extends NotificationLog {
  const NotificationLogModel({
    super.id,
    required super.reminderId,
    required super.sentAt,
    required super.message,
    super.interaction,
  });

  factory NotificationLogModel.fromMap(Map<String, dynamic> map) {
    return NotificationLogModel(
      id: map[DbConstants.colId] as int?,
      reminderId: map[DbConstants.colNlRemId] as int,
      sentAt: DateTime.parse(map[DbConstants.colNlSentAt] as String),
      message: map[DbConstants.colNlMessage] as String,
      interaction:
          (map[DbConstants.colNlInteract] as String?) ?? NotificationLog.interactionIgnored,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colNlRemId: reminderId,
        DbConstants.colNlSentAt: sentAt.toIso8601String(),
        DbConstants.colNlMessage: message,
        DbConstants.colNlInteract: interaction,
      };

  factory NotificationLogModel.fromEntity(NotificationLog l) =>
      NotificationLogModel(
        id: l.id,
        reminderId: l.reminderId,
        sentAt: l.sentAt,
        message: l.message,
        interaction: l.interaction,
      );
}
