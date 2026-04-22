import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/database_helper.dart';
import '../../data/repositories/routine_repository_impl.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../data/repositories/cardio_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/repositories/i_routine_repository.dart';
import '../../domain/repositories/i_workout_repository.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../../domain/repositories/i_cardio_repository.dart';
import '../../domain/repositories/i_reminder_repository.dart';

// ── Infraestructura ────────────────────────────────────────────────────────
final databaseHelperProvider = Provider<DatabaseHelper>(
  (_) => DatabaseHelper.instance,
);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override en main() con el valor real');
});

// ── Repositorios ───────────────────────────────────────────────────────────
final routineRepositoryProvider = Provider<IRoutineRepository>(
  (ref) => RoutineRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final workoutRepositoryProvider = Provider<IWorkoutRepository>(
  (ref) => WorkoutRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final exerciseRepositoryProvider = Provider<IExerciseRepository>(
  (ref) => ExerciseRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final cardioRepositoryProvider = Provider<ICardioRepository>(
  (ref) => CardioRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final reminderRepositoryProvider = Provider<IReminderRepository>(
  (ref) => ReminderRepositoryImpl(ref.watch(databaseHelperProvider)),
);

// ── Preferencias ───────────────────────────────────────────────────────────
final unitProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('unit') ?? 'kg';
});

final themeProvider = StateProvider<bool>((ref) {
  // true = dark (por defecto)
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('dark_theme') ?? true;
});
