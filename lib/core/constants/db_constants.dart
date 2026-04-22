class DbConstants {
  DbConstants._();

  static const String dbName    = 'workout_tracker.db';
  static const int    dbVersion = 1;

  // ── Tablas ────────────────────────────────────────────────────────────────
  static const String tableRoutines               = 'routines';
  static const String tableDays                   = 'days';
  static const String tableExercises              = 'exercises';
  static const String tableExerciseLibrary        = 'exercise_library';
  static const String tableWorkoutSessions        = 'workout_sessions';
  static const String tableSetLogs                = 'set_logs';
  static const String tableExerciseSwaps          = 'exercise_swaps';
  static const String tableCardioPlan             = 'cardio_plans';
  static const String tableCardioWeeks            = 'cardio_weeks';
  static const String tableCardioSessionTemplates = 'cardio_session_templates';
  static const String tableCardioSessionLogs      = 'cardio_session_logs';
  static const String tableReminders              = 'reminders';
  static const String tableNotificationLogs       = 'notification_logs';

  // ── Columnas comunes ──────────────────────────────────────────────────────
  static const String colId        = 'id';
  static const String colCreatedAt = 'created_at';

  // ── routines ──────────────────────────────────────────────────────────────
  static const String colRoutineName        = 'name';
  static const String colRoutineDescription = 'description';
  static const String colRoutineUpdatedAt   = 'updated_at';

  // ── days ──────────────────────────────────────────────────────────────────
  static const String colDayRoutineId = 'routine_id';
  static const String colDayName      = 'name';
  static const String colDayOrder     = 'order_index';

  // ── exercises ─────────────────────────────────────────────────────────────
  static const String colExDayId      = 'day_id';
  static const String colExName       = 'name';
  static const String colExMuscle     = 'muscle_group';
  static const String colExSets       = 'target_sets';
  static const String colExRepMin     = 'rep_range_min';
  static const String colExRepMax     = 'rep_range_max';
  static const String colExRir        = 'rir_target';
  static const String colExNotes      = 'notes';
  static const String colExOrder      = 'order_index';
  static const String colExRest       = 'rest_seconds';
  static const String colExCompound   = 'is_compound';
  static const String colExLibraryId  = 'library_id';

  // ── exercise_library ──────────────────────────────────────────────────────
  static const String colLibName     = 'name';
  static const String colLibMuscle   = 'muscle_group';
  static const String colLibCompound = 'is_compound';
  static const String colLibCustom   = 'is_custom';

  // ── workout_sessions ──────────────────────────────────────────────────────
  static const String colSessDayId    = 'day_id';
  static const String colSessDate     = 'date';
  static const String colSessDuration = 'duration_seconds';
  static const String colSessNotes    = 'notes';
  static const String colSessFeeling  = 'feeling';
  static const String colSessCompleted = 'completed';

  // ── set_logs ──────────────────────────────────────────────────────────────
  static const String colSetSessionId  = 'session_id';
  static const String colSetExerciseId = 'exercise_id';
  static const String colSetNumber     = 'set_number';
  static const String colSetWeight     = 'weight_kg';
  static const String colSetReps       = 'reps_done';
  static const String colSetRir        = 'rir';
  static const String colSetCompleted  = 'completed';
  static const String colSetNotes      = 'notes';

  // ── exercise_swaps ────────────────────────────────────────────────────────
  static const String colSwapOrigId   = 'original_exercise_id';
  static const String colSwapSubId    = 'substitute_exercise_id';
  static const String colSwapSessId   = 'session_id';
  static const String colSwapDate     = 'date';
  static const String colSwapReason   = 'reason';
  static const String colSwapPermanent = 'is_permanent';

  // ── cardio_plans ──────────────────────────────────────────────────────────
  static const String colPlanName        = 'name';
  static const String colPlanDescription = 'description';
  static const String colPlanStartDate   = 'start_date';
  static const String colPlanCurrentWeek = 'current_week';

  // ── cardio_weeks ──────────────────────────────────────────────────────────
  static const String colWeekPlanId      = 'plan_id';
  static const String colWeekNumber      = 'week_number';
  static const String colWeekObjective   = 'objective';
  static const String colWeekTargetSess  = 'target_sessions';

  // ── cardio_session_templates ──────────────────────────────────────────────
  static const String colCstWeekId    = 'week_id';
  static const String colCstName      = 'name';
  static const String colCstType      = 'type';
  static const String colCstDuration  = 'estimated_duration';
  static const String colCstDesc      = 'description';
  static const String colCstCompleted = 'completed';

  // ── cardio_session_logs ───────────────────────────────────────────────────
  static const String colCslTemplateId = 'template_id';
  static const String colCslDate       = 'date';
  static const String colCslDuration   = 'real_duration';
  static const String colCslDistance   = 'distance';
  static const String colCslAvgHr      = 'avg_hr';
  static const String colCslMaxHr      = 'max_hr';
  static const String colCslSpeed      = 'speed';
  static const String colCslIncline    = 'incline';
  static const String colCslFeeling    = 'feeling';
  static const String colCslNotes      = 'notes';

  // ── reminders ─────────────────────────────────────────────────────────────
  static const String colRemType        = 'type';
  static const String colRemTime        = 'scheduled_time';
  static const String colRemDays        = 'active_days_bitmask';
  static const String colRemActive      = 'is_active';
  static const String colRemPersonality = 'personality';
  static const String colRemPostpone    = 'postpone_count';

  // ── notification_logs ─────────────────────────────────────────────────────
  static const String colNlRemId    = 'reminder_id';
  static const String colNlSentAt   = 'sent_at';
  static const String colNlMessage  = 'message';
  static const String colNlInteract = 'interaction';
}
