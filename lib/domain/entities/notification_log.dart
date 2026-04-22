class NotificationLog {
  final int? id;
  final int reminderId;
  final DateTime sentAt;
  final String message;
  final String interaction; // 'ignorada' | 'abierta' | 'completada' | 'favorita' | 'blacklist'

  const NotificationLog({
    this.id,
    required this.reminderId,
    required this.sentAt,
    required this.message,
    this.interaction = 'ignorada',
  });

  static const String interactionIgnored   = 'ignorada';
  static const String interactionOpened    = 'abierta';
  static const String interactionCompleted = 'completada';
  static const String interactionFavorite  = 'favorita';
  static const String interactionBlacklist = 'blacklist';

  NotificationLog copyWith({
    int? id,
    int? reminderId,
    DateTime? sentAt,
    String? message,
    String? interaction,
  }) =>
      NotificationLog(
        id: id ?? this.id,
        reminderId: reminderId ?? this.reminderId,
        sentAt: sentAt ?? this.sentAt,
        message: message ?? this.message,
        interaction: interaction ?? this.interaction,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NotificationLog && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
