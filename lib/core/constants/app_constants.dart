class AppConstants {
  AppConstants._();

  static const String appName = 'WorkoutTracker';
  static const String appVersion = '1.0.0';

  // Unidades
  static const String unitKg = 'kg';
  static const String unitLb = 'lb';
  static const double kgToLb = 2.20462;

  // Descanso por defecto (segundos)
  static const int defaultRestCompound = 180;
  static const int defaultRestAccessory = 90;

  // Placa calculadora
  static const double defaultBarWeightKg = 20.0;
  static const List<double> availablePlates = [
    20.0, 15.0, 10.0, 5.0, 2.5, 1.25, 0.5, 0.25,
  ];

  // Grupos musculares
  static const String muscleChest = 'Pecho';
  static const String muscleBack = 'Espalda';
  static const String muscleShoulders = 'Hombros';
  static const String muscleBiceps = 'Bíceps';
  static const String muscleTriceps = 'Tríceps';
  static const String muscleLegs = 'Piernas';
  static const String muscleGlutes = 'Glúteos';
  static const String muscleCalves = 'Gemelos';
  static const String muscleCore = 'Core';
  static const String muscleForearms = 'Antebrazos';

  static const List<String> allMuscleGroups = [
    muscleChest, muscleBack, muscleShoulders, muscleBiceps, muscleTriceps,
    muscleLegs, muscleGlutes, muscleCalves, muscleCore, muscleForearms,
  ];

  // Tipos de cardio
  static const String cardioWalk = 'caminata';
  static const String cardioWalkRun = 'walk_run';
  static const String cardioJog = 'trote_continuo';
  static const String cardioHiit = 'hiit';

  static const List<String> cardioTypes = [
    cardioWalk, cardioWalkRun, cardioJog, cardioHiit,
  ];

  static const Map<String, String> cardioTypeLabels = {
    cardioWalk: 'Caminata',
    cardioWalkRun: 'Walk-run',
    cardioJog: 'Trote continuo',
    cardioHiit: 'HIIT',
  };

  // Días de la semana como bitmask (Lunes=1, Martes=2, Miércoles=4, ...)
  static const int dayMonday    = 1;
  static const int dayTuesday   = 2;
  static const int dayWednesday = 4;
  static const int dayThursday  = 8;
  static const int dayFriday    = 16;
  static const int daySaturday  = 32;
  static const int daySunday    = 64;
  static const int dayAllWeek   = 127;

  // Personalidades de recordatorio
  static const String personalityEpic         = 'epico';
  static const String personalitySarcastic    = 'sarcastico';
  static const String personalityMotivational = 'motivacional';
  static const String personalityFriendly     = 'amistoso';
  static const String personalityMilitary     = 'militar';

  static const List<String> allPersonalities = [
    personalityEpic, personalitySarcastic, personalityMotivational,
    personalityFriendly, personalityMilitary,
  ];

  static const Map<String, String> personalityLabels = {
    personalityEpic:         'Épico',
    personalitySarcastic:    'Sarcástico',
    personalityMotivational: 'Motivacional',
    personalityFriendly:     'Amistoso',
    personalityMilitary:     'Militar',
  };

  // Tipos de recordatorio
  static const String reminderGym         = 'gym';
  static const String reminderCardio      = 'cardio';
  static const String reminderWeigh       = 'peso_corporal';
  static const String reminderMeasure     = 'medidas';
  static const String reminderHydration   = 'agua';
  static const String reminderDeload      = 'descanso';
  static const String reminderMotivational = 'motivacional';

  // IDs de notificación (base; se multiplica por reminder id para evitar colisiones)
  static const int notifBaseId = 1000;

  // SharedPreferences keys
  static const String prefUnit            = 'unit';
  static const String prefTheme           = 'theme';
  static const String prefRestCompound    = 'rest_compound';
  static const String prefRestAccessory   = 'rest_accessory';
  static const String prefBarWeight       = 'bar_weight';
  static const String prefUserName        = 'user_name';
  static const String prefUserAge         = 'user_age';
  static const String prefWorkoutTime     = 'workout_time_hhmm'; // "07:00"
  static const String prefOnboardingDone  = 'onboarding_done';
  static const String prefSeededDb        = 'seeded_db_v1';
  static const String prefMessageBlacklist = 'message_blacklist';
}
