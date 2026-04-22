class Reminder {
  final int? id;
  final String type; // AppConstants.reminder*
  final String scheduledTime; // "HH:mm"
  final int activeDaysBitmask; // L=1 M=2 X=4 J=8 V=16 S=32 D=64
  final bool isActive;
  final String personality; // AppConstants.personality*
  /// Veces seguidas que el usuario ha pospuesto este recordatorio.
  /// Al llegar a 3 se fuerza tono sarcástico para ese envío.
  final int postponeCount;

  const Reminder({
    this.id,
    required this.type,
    required this.scheduledTime,
    this.activeDaysBitmask = 127,
    this.isActive = true,
    required this.personality,
    this.postponeCount = 0,
  });

  Reminder copyWith({
    int? id,
    String? type,
    String? scheduledTime,
    int? activeDaysBitmask,
    bool? isActive,
    String? personality,
    int? postponeCount,
  }) =>
      Reminder(
        id: id ?? this.id,
        type: type ?? this.type,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        activeDaysBitmask: activeDaysBitmask ?? this.activeDaysBitmask,
        isActive: isActive ?? this.isActive,
        personality: personality ?? this.personality,
        postponeCount: postponeCount ?? this.postponeCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Reminder && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'Reminder($id, $type, $scheduledTime)';
}
