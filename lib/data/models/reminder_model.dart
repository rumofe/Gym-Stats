import '../../domain/entities/reminder.dart';
import '../../core/constants/db_constants.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    super.id,
    required super.type,
    required super.scheduledTime,
    super.activeDaysBitmask,
    super.isActive,
    required super.personality,
    super.postponeCount,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map[DbConstants.colId] as int?,
      type: map[DbConstants.colRemType] as String,
      scheduledTime: map[DbConstants.colRemTime] as String,
      activeDaysBitmask: (map[DbConstants.colRemDays] as int?) ?? 127,
      isActive: ((map[DbConstants.colRemActive] as int?) ?? 1) == 1,
      personality: map[DbConstants.colRemPersonality] as String,
      postponeCount: (map[DbConstants.colRemPostpone] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.colId: id,
        DbConstants.colRemType: type,
        DbConstants.colRemTime: scheduledTime,
        DbConstants.colRemDays: activeDaysBitmask,
        DbConstants.colRemActive: isActive ? 1 : 0,
        DbConstants.colRemPersonality: personality,
        DbConstants.colRemPostpone: postponeCount,
      };

  factory ReminderModel.fromEntity(Reminder r) => ReminderModel(
        id: r.id,
        type: r.type,
        scheduledTime: r.scheduledTime,
        activeDaysBitmask: r.activeDaysBitmask,
        isActive: r.isActive,
        personality: r.personality,
        postponeCount: r.postponeCount,
      );
}
