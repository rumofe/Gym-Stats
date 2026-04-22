import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/db_constants.dart';

/// Inserta la rutina Upper/Lower 4 días, el plan de cardio de 8 semanas,
/// la biblioteca de ejercicios y los recordatorios por defecto.
/// Se llama solo una vez (controlado por SharedPreferences prefSeededDb).
class InitialDataSeeder {
  const InitialDataSeeder._();

  static Future<void> seed(Database db) async {
    await db.transaction((txn) async {
      await _seedExerciseLibrary(txn);
      await _seedRoutine(txn);
      await _seedCardioPlan(txn);
      await _seedReminders(txn);
    });
  }

  // ── Biblioteca de ejercicios (65 ejercicios) ──────────────────────────────
  static Future<void> _seedExerciseLibrary(Transaction txn) async {
    final exercises = [
      // Pecho
      _lib('Press banca barra',            AppConstants.muscleChest,     compound: true),
      _lib('Press banca inclinado barra',  AppConstants.muscleChest,     compound: true),
      _lib('Press banca declinado barra',  AppConstants.muscleChest,     compound: true),
      _lib('Press banca mancuernas',       AppConstants.muscleChest,     compound: true),
      _lib('Press inclinado mancuernas',   AppConstants.muscleChest,     compound: true),
      _lib('Aperturas mancuernas',         AppConstants.muscleChest),
      _lib('Cruces en polea',              AppConstants.muscleChest),
      _lib('Pullover polea',               AppConstants.muscleChest),
      // Espalda
      _lib('Remo barra',                   AppConstants.muscleBack,      compound: true),
      _lib('Remo mancuerna',               AppConstants.muscleBack,      compound: true),
      _lib('Remo polea baja',              AppConstants.muscleBack,      compound: true),
      _lib('Jalón al pecho',               AppConstants.muscleBack,      compound: true),
      _lib('Dominadas',                    AppConstants.muscleBack,      compound: true),
      _lib('Dominadas lastradas',          AppConstants.muscleBack,      compound: true),
      _lib('Peso muerto convencional',     AppConstants.muscleBack,      compound: true),
      _lib('Rack pull',                    AppConstants.muscleBack,      compound: true),
      _lib('Remo en máquina',              AppConstants.muscleBack),
      _lib('Remo Pendlay',                 AppConstants.muscleBack,      compound: true),
      // Hombros
      _lib('Press militar barra',          AppConstants.muscleShoulders, compound: true),
      _lib('Press militar mancuernas',     AppConstants.muscleShoulders, compound: true),
      _lib('Press Arnold',                 AppConstants.muscleShoulders, compound: true),
      _lib('Elevaciones laterales',        AppConstants.muscleShoulders),
      _lib('Elevaciones frontales',        AppConstants.muscleShoulders),
      _lib('Face pulls',                   AppConstants.muscleShoulders),
      _lib('Pájaros',                      AppConstants.muscleShoulders),
      // Bíceps
      _lib('Curl barra',                   AppConstants.muscleBiceps),
      _lib('Curl mancuernas',              AppConstants.muscleBiceps),
      _lib('Curl martillo',                AppConstants.muscleBiceps),
      _lib('Curl concentrado',             AppConstants.muscleBiceps),
      _lib('Curl araña',                   AppConstants.muscleBiceps),
      _lib('Curl predicador',              AppConstants.muscleBiceps),
      _lib('Curl en polea',                AppConstants.muscleBiceps),
      // Tríceps
      _lib('Extensión tríceps polea',      AppConstants.muscleTriceps),
      _lib('Fondos paralelas',             AppConstants.muscleTriceps,   compound: true),
      _lib('Press francés',                AppConstants.muscleTriceps),
      _lib('Extensión sobre cabeza',       AppConstants.muscleTriceps),
      _lib('Kickback mancuerna',           AppConstants.muscleTriceps),
      _lib('Rompecráneos',                 AppConstants.muscleTriceps),
      _lib('Press banca agarre cerrado',   AppConstants.muscleTriceps,   compound: true),
      // Piernas
      _lib('Sentadilla trasera',           AppConstants.muscleLegs,      compound: true),
      _lib('Sentadilla frontal',           AppConstants.muscleLegs,      compound: true),
      _lib('Sentadilla goblet',            AppConstants.muscleLegs,      compound: true),
      _lib('Peso muerto rumano',           AppConstants.muscleLegs,      compound: true),
      _lib('Peso muerto sumo',             AppConstants.muscleLegs,      compound: true),
      _lib('Prensa inclinada',             AppConstants.muscleLegs,      compound: true),
      _lib('Hack o prensa',                AppConstants.muscleLegs,      compound: true),
      _lib('Zancadas búlgaras',            AppConstants.muscleLegs,      compound: true),
      _lib('Zancadas caminando',           AppConstants.muscleLegs,      compound: true),
      _lib('Extensión cuádriceps',         AppConstants.muscleLegs),
      _lib('Curl femoral tumbado',         AppConstants.muscleLegs),
      _lib('Curl femoral sentado',         AppConstants.muscleLegs),
      _lib('Good morning',                 AppConstants.muscleLegs,      compound: true),
      // Glúteos
      _lib('Hip thrust',                   AppConstants.muscleGlutes,    compound: true),
      _lib('Hip thrust mancuerna',         AppConstants.muscleGlutes),
      _lib('Puente de glúteo',             AppConstants.muscleGlutes),
      _lib('Abducción en polea',           AppConstants.muscleGlutes),
      // Gemelos
      _lib('Gemelo de pie',                AppConstants.muscleCalves),
      _lib('Gemelo sentado',               AppConstants.muscleCalves),
      _lib('Gemelo en prensa',             AppConstants.muscleCalves),
      // Core
      _lib('Plancha',                      AppConstants.muscleCore),
      _lib('Plancha lateral',              AppConstants.muscleCore),
      _lib('Abs en polea',                 AppConstants.muscleCore),
      _lib('Rueda abdominal',              AppConstants.muscleCore),
      _lib('Elevación de piernas',         AppConstants.muscleCore),
      _lib('Russian twist',                AppConstants.muscleCore),
    ];

    for (final ex in exercises) {
      await txn.insert(DbConstants.tableExerciseLibrary, ex);
    }
  }

  static Map<String, dynamic> _lib(String name, String muscle,
      {bool compound = false}) =>
      {
        DbConstants.colLibName: name,
        DbConstants.colLibMuscle: muscle,
        DbConstants.colLibCompound: compound ? 1 : 0,
        DbConstants.colLibCustom: 0,
      };

  // ── Rutina Upper/Lower 4 días ──────────────────────────────────────────────
  static Future<void> _seedRoutine(Transaction txn) async {
    final now = DateTime.now().toIso8601String();
    final routineId = await txn.insert(DbConstants.tableRoutines, {
      DbConstants.colRoutineName: 'Upper/Lower — Definición Avanzado',
      DbConstants.colRoutineDescription:
          'Rutina Upper/Lower 4 días para fase de definición, nivel avanzado. '
          'Énfasis en preservación muscular en déficit calórico.',
      DbConstants.colCreatedAt: now,
      DbConstants.colRoutineUpdatedAt: now,
    });

    // ── Día 1: Upper A ────────────────────────────────────────────────────
    final day1 = await txn.insert(DbConstants.tableDays, {
      DbConstants.colDayRoutineId: routineId,
      DbConstants.colDayName: 'Upper A',
      DbConstants.colDayOrder: 0,
    });
    await _seedExercisesForDay(txn, day1, [
      _ex('Press banca barra',           AppConstants.muscleChest,     4, 5,  7,  1, compound: true,  rest: 180),
      _ex('Remo barra',                  AppConstants.muscleBack,      4, 6,  8,  1, compound: true,  rest: 180),
      _ex('Press militar mancuernas',    AppConstants.muscleShoulders, 3, 8,  10, 2, compound: true,  rest: 150),
      _ex('Dominadas lastradas',         AppConstants.muscleBack,      3, 6,  8,  1, compound: true,  rest: 180),
      _ex('Press inclinado mancuernas',  AppConstants.muscleChest,     3, 10, 12, 2, compound: false, rest: 120),
      _ex('Face pulls',                  AppConstants.muscleShoulders, 3, 12, 15, 2, compound: false, rest: 90),
      _ex('Curl barra',                  AppConstants.muscleBiceps,    3, 10, 12, 2, compound: false, rest: 90),
      _ex('Extensión tríceps polea',     AppConstants.muscleTriceps,   3, 10, 12, 2, compound: false, rest: 90),
    ]);

    // ── Día 2: Lower A ────────────────────────────────────────────────────
    final day2 = await txn.insert(DbConstants.tableDays, {
      DbConstants.colDayRoutineId: routineId,
      DbConstants.colDayName: 'Lower A',
      DbConstants.colDayOrder: 1,
    });
    await _seedExercisesForDay(txn, day2, [
      _ex('Sentadilla trasera',    AppConstants.muscleLegs,   4, 5,  7,  1, compound: true,  rest: 240),
      _ex('Peso muerto rumano',    AppConstants.muscleLegs,   3, 8,  10, 2, compound: true,  rest: 180),
      _ex('Prensa inclinada',      AppConstants.muscleLegs,   3, 10, 12, 2, compound: true,  rest: 150),
      _ex('Zancadas búlgaras',     AppConstants.muscleLegs,   3, 10, 10, 2, compound: true,  rest: 120),
      _ex('Extensión cuádriceps',  AppConstants.muscleLegs,   3, 12, 15, 2, compound: false, rest: 90),
      _ex('Gemelo de pie',         AppConstants.muscleCalves, 4, 10, 15, 2, compound: false, rest: 60),
      _ex('Plancha',               AppConstants.muscleCore,   3, 0,  0,  0, compound: false, rest: 60,
          notes: '3×45s. Reps=45 (segundos).'),
    ]);

    // ── Día 3: Upper B ────────────────────────────────────────────────────
    final day3 = await txn.insert(DbConstants.tableDays, {
      DbConstants.colDayRoutineId: routineId,
      DbConstants.colDayName: 'Upper B',
      DbConstants.colDayOrder: 2,
    });
    await _seedExercisesForDay(txn, day3, [
      _ex('Peso muerto convencional',      AppConstants.muscleBack,      3, 4,  6,  1, compound: true,  rest: 240),
      _ex('Press banca inclinado barra',   AppConstants.muscleChest,     4, 6,  8,  1, compound: true,  rest: 180),
      _ex('Remo polea baja',               AppConstants.muscleBack,      3, 8,  10, 2, compound: true,  rest: 150),
      _ex('Press Arnold',                  AppConstants.muscleShoulders, 3, 10, 12, 2, compound: true,  rest: 120),
      _ex('Jalón al pecho',                AppConstants.muscleBack,      3, 10, 12, 2, compound: false, rest: 120),
      _ex('Elevaciones laterales',         AppConstants.muscleShoulders, 4, 12, 15, 2, compound: false, rest: 90),
      _ex('Curl martillo',                 AppConstants.muscleBiceps,    3, 10, 12, 2, compound: false, rest: 90),
      _ex('Fondos paralelas',              AppConstants.muscleTriceps,   3, 10, 12, 2, compound: true,  rest: 120),
    ]);

    // ── Día 4: Lower B ────────────────────────────────────────────────────
    final day4 = await txn.insert(DbConstants.tableDays, {
      DbConstants.colDayRoutineId: routineId,
      DbConstants.colDayName: 'Lower B',
      DbConstants.colDayOrder: 3,
    });
    await _seedExercisesForDay(txn, day4, [
      _ex('Peso muerto rumano',    AppConstants.muscleLegs,   4, 6,  8,  1, compound: true,  rest: 180),
      _ex('Hip thrust',            AppConstants.muscleGlutes, 4, 8,  10, 2, compound: true,  rest: 150),
      _ex('Sentadilla frontal',    AppConstants.muscleLegs,   3, 8,  10, 2, compound: true,  rest: 180),
      _ex('Curl femoral tumbado',  AppConstants.muscleLegs,   3, 10, 12, 2, compound: false, rest: 90),
      _ex('Hack o prensa',         AppConstants.muscleLegs,   3, 12, 15, 2, compound: true,  rest: 120),
      _ex('Gemelo sentado',        AppConstants.muscleCalves, 4, 15, 20, 2, compound: false, rest: 60),
      _ex('Abs en polea',          AppConstants.muscleCore,   3, 12, 15, 2, compound: false, rest: 60),
    ]);
  }

  static Future<void> _seedExercisesForDay(
    Transaction txn,
    int dayId,
    List<Map<String, dynamic>> exercises,
  ) async {
    for (var i = 0; i < exercises.length; i++) {
      await txn.insert(DbConstants.tableExercises,
          {...exercises[i], DbConstants.colExDayId: dayId, DbConstants.colExOrder: i});
    }
  }

  static Map<String, dynamic> _ex(
    String name,
    String muscle,
    int sets,
    int repMin,
    int repMax,
    int rir, {
    bool compound = false,
    int rest = 90,
    String notes = '',
  }) =>
      {
        DbConstants.colExName: name,
        DbConstants.colExMuscle: muscle,
        DbConstants.colExSets: sets,
        DbConstants.colExRepMin: repMin,
        DbConstants.colExRepMax: repMax,
        DbConstants.colExRir: rir,
        DbConstants.colExCompound: compound ? 1 : 0,
        DbConstants.colExRest: rest,
        DbConstants.colExNotes: notes,
      };

  // ── Plan de cardio 8 semanas ───────────────────────────────────────────────
  static Future<void> _seedCardioPlan(Transaction txn) async {
    final startDate = DateTime.now().toIso8601String();
    final planId = await txn.insert(DbConstants.tableCardioPlan, {
      DbConstants.colPlanName: 'Base Aeróbica — 8 Semanas',
      DbConstants.colPlanDescription:
          'Construcción de base aeróbica desde condición baja tras volumen. '
          'Objetivo: Zona 2 sin interferencia con preservación muscular en déficit. '
          'Regla clave: si no puedes hablar con frases cortas, vas demasiado rápido.',
      DbConstants.colPlanStartDate: startDate,
      DbConstants.colPlanCurrentWeek: 1,
    });

    final weeks = [
      _week(planId, 1,
        objective: 'Sostener 30 min sin elevar demasiado la FC. Ritmo conversacional.',
        sessions: [
          _cst(AppConstants.cardioWalk, 'Caminata inclinada', 30,
              '5 min calentamiento andando plano + 20 min a 5–5,5 km/h inclinación 3–5 % '
              '+ 5 min enfriamiento. FC objetivo Zona 2 (hablar con frases cortas).'),
          _cst(AppConstants.cardioWalk, 'Caminata inclinada', 30,
              '5 min calentamiento andando plano + 20 min a 5–5,5 km/h inclinación 3–5 % '
              '+ 5 min enfriamiento. FC objetivo Zona 2.'),
          _cst(AppConstants.cardioWalk, 'Caminata inclinada', 30,
              '5 min calentamiento andando plano + 20 min a 5–5,5 km/h inclinación 3–5 % '
              '+ 5 min enfriamiento. FC objetivo Zona 2.'),
        ],
      ),
      _week(planId, 2,
        objective: 'Mismo volumen que semana 1. Nota que te cuesta menos que el primer día.',
        sessions: [
          _cst(AppConstants.cardioWalk, 'Caminata inclinada', 30,
              '5 min calentamiento + 20 min a 5,5 km/h inclinación 4–6 % + 5 min enfriamiento.'),
          _cst(AppConstants.cardioWalk, 'Caminata inclinada', 30,
              '5 min calentamiento + 20 min a 5,5 km/h inclinación 4–6 % + 5 min enfriamiento.'),
          _cst(AppConstants.cardioWalk, 'Caminata inclinada', 30,
              '5 min calentamiento + 20 min a 5,5 km/h inclinación 4–6 % + 5 min enfriamiento.'),
        ],
      ),
      _week(planId, 3,
        objective: 'Tolerar bloques cortos de trote sin ahogo. Si te ahogas a los 30s, baja velocidad.',
        sessions: [
          _cst(AppConstants.cardioWalkRun, 'Walk-run 1/2 ×7', 36,
              '5 min calentamiento caminando + '
              '[1 min trote 7–7,5 km/h + 2 min caminar 5,5 km/h] × 7 + '
              '5 min enfriamiento. LENTO. Si te ahogas, baja a 6,5 km/h.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 1/2 ×7', 36,
              '5 min calentamiento caminando + '
              '[1 min trote 7–7,5 km/h + 2 min caminar 5,5 km/h] × 7 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 1/2 ×7', 36,
              '5 min calentamiento caminando + '
              '[1 min trote 7–7,5 km/h + 2 min caminar 5,5 km/h] × 7 + '
              '5 min enfriamiento.'),
        ],
      ),
      _week(planId, 4,
        objective: 'Completar los 8 bloques sin saltarte ninguno. Consolidación.',
        sessions: [
          _cst(AppConstants.cardioWalkRun, 'Walk-run 1/2 ×8', 39,
              '5 min calentamiento + '
              '[1 min trote 7–7,5 km/h + 2 min caminar 5,5 km/h] × 8 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 1/2 ×8', 39,
              '5 min calentamiento + '
              '[1 min trote + 2 min caminar] × 8 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 1/2 ×8', 39,
              '5 min calentamiento + '
              '[1 min trote + 2 min caminar] × 8 + '
              '5 min enfriamiento.'),
        ],
      ),
      _week(planId, 5,
        objective: 'Igualar tiempo de trote y tiempo de caminata.',
        sessions: [
          _cst(AppConstants.cardioWalkRun, 'Walk-run 2/2 ×7', 38,
              '5 min calentamiento + '
              '[2 min trote 7–7,5 km/h + 2 min caminar 5,5 km/h] × 7 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 2/2 ×7', 38,
              '5 min calentamiento + '
              '[2 min trote + 2 min caminar] × 7 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalk, 'Caminata larga inclinada', 40,
              '40 min a 5,5 km/h inclinación 6–8 %. Recuperación activa, ideal en día de pierna.'),
        ],
      ),
      _week(planId, 6,
        objective: 'El trote domina el tiempo total. La caminata es solo recuperación.',
        sessions: [
          _cst(AppConstants.cardioWalkRun, 'Walk-run 3/1 ×6', 34,
              '5 min calentamiento + '
              '[3 min trote 7–7,5 km/h + 1 min caminar 5,5 km/h] × 6 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 3/1 ×6', 34,
              '5 min calentamiento + '
              '[3 min trote + 1 min caminar] × 6 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalk, 'Caminata larga inclinada', 45,
              '45 min a 5,5–6 km/h inclinación 6–8 %. Ritmo conversacional.'),
        ],
      ),
      _week(planId, 7,
        objective: 'Primera sesión de trote continuo. No te pases de velocidad.',
        sessions: [
          _cst(AppConstants.cardioJog, 'Trote continuo 15-20min', 30,
              '5 min calentamiento caminando + '
              '15–20 min trote continuo a ritmo conversacional (puedes hablar frases cortas) + '
              '5 min enfriamiento caminando. Si no aguantas, alterna 5 min trote / 1 min caminar.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 3/1 ×7', 38,
              '5 min calentamiento + '
              '[3 min trote + 1 min caminar] × 7 + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalk, 'Caminata larga inclinada', 45,
              '45 min a 5,5–6 km/h inclinación 6–8 %.'),
        ],
      ),
      _week(planId, 8,
        objective: 'Consolidación base aeróbica. 25 min continuos marca personal. ¡Eso es una base sólida!',
        sessions: [
          _cst(AppConstants.cardioJog, 'Trote continuo 25min', 35,
              '5 min calentamiento + '
              '25 min trote continuo a ritmo conversacional + '
              '5 min enfriamiento. Si necesitas, 1 min de caminata a mitad. '
              'Velocidad orientativa: 6,5–7,5 km/h según condición.'),
          _cst(AppConstants.cardioWalkRun, 'Walk-run 3/1 ×7-8', 40,
              '5 min calentamiento + '
              '[3 min trote + 1 min caminar] × 7-8 rondas + '
              '5 min enfriamiento.'),
          _cst(AppConstants.cardioWalk, 'Caminata larga inclinada alta', 45,
              '45 min a 5,5–6 km/h inclinación 8–10 %. La más dura hasta ahora.'),
        ],
      ),
    ];

    for (final weekData in weeks) {
      final sessions = weekData['sessions'] as List<Map<String, dynamic>>;
      final weekMap = Map<String, dynamic>.from(weekData)..remove('sessions');
      final weekId = await txn.insert(DbConstants.tableCardioWeeks, weekMap);
      for (final s in sessions) {
        await txn.insert(DbConstants.tableCardioSessionTemplates,
            {...s, DbConstants.colCstWeekId: weekId});
      }
    }
  }

  static Map<String, dynamic> _week(
    int planId,
    int number, {
    required String objective,
    required List<Map<String, dynamic>> sessions,
  }) =>
      {
        DbConstants.colWeekPlanId: planId,
        DbConstants.colWeekNumber: number,
        DbConstants.colWeekObjective: objective,
        DbConstants.colWeekTargetSess: sessions.length,
        'sessions': sessions,
      };

  static Map<String, dynamic> _cst(
    String type,
    String name,
    int duration,
    String description,
  ) =>
      {
        DbConstants.colCstType: type,
        DbConstants.colCstName: name,
        DbConstants.colCstDuration: duration,
        DbConstants.colCstDesc: description,
        DbConstants.colCstCompleted: 0,
      };

  // ── Recordatorios por defecto ─────────────────────────────────────────────
  static Future<void> _seedReminders(Transaction txn) async {
    final reminders = [
      // Gym: Lun+Mar+Jue+Vie (1+2+8+16=27), 1h antes del entreno
      // La hora real se ajusta en onboarding; aquí ponemos 08:00 como placeholder
      {
        DbConstants.colRemType: AppConstants.reminderGym,
        DbConstants.colRemTime: '08:00',
        DbConstants.colRemDays: AppConstants.dayMonday | AppConstants.dayTuesday |
            AppConstants.dayThursday | AppConstants.dayFriday,
        DbConstants.colRemActive: 1,
        DbConstants.colRemPersonality: AppConstants.personalitySarcastic,
        DbConstants.colRemPostpone: 0,
      },
      // Cardio: Mié+Sáb+Dom (4+32+64=100)
      {
        DbConstants.colRemType: AppConstants.reminderCardio,
        DbConstants.colRemTime: '09:00',
        DbConstants.colRemDays: AppConstants.dayWednesday | AppConstants.daySaturday |
            AppConstants.daySunday,
        DbConstants.colRemActive: 1,
        DbConstants.colRemPersonality: AppConstants.personalityMotivational,
        DbConstants.colRemPostpone: 0,
      },
      // Pesaje: Sábados 08:00
      {
        DbConstants.colRemType: AppConstants.reminderWeigh,
        DbConstants.colRemTime: '08:00',
        DbConstants.colRemDays: AppConstants.daySaturday,
        DbConstants.colRemActive: 1,
        DbConstants.colRemPersonality: AppConstants.personalityFriendly,
        DbConstants.colRemPostpone: 0,
      },
      // Motivacional: Lun+Jue (1+8=9)
      {
        DbConstants.colRemType: AppConstants.reminderMotivational,
        DbConstants.colRemTime: '12:00',
        DbConstants.colRemDays: AppConstants.dayMonday | AppConstants.dayThursday,
        DbConstants.colRemActive: 1,
        DbConstants.colRemPersonality: AppConstants.personalitySarcastic,
        DbConstants.colRemPostpone: 0,
      },
    ];

    for (final r in reminders) {
      await txn.insert(DbConstants.tableReminders, r);
    }
  }
}
