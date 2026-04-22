import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/calculation_utils.dart';
import '../../domain/entities/day.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/set_log.dart';
import '../../domain/entities/exercise_swap.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/i_workout_repository.dart';
import '../../domain/repositories/i_routine_repository.dart';
import 'providers.dart';

// ── Estado ────────────────────────────────────────────────────────────────

/// Borrador de una serie (in-memory mientras el usuario edita).
class SetDraft {
  final double weightKg;
  final int reps;
  final int? rir;
  final String notes;
  final bool completed;
  final bool isPR;

  const SetDraft({
    this.weightKg = 0,
    this.reps = 0,
    this.rir,
    this.notes = '',
    this.completed = false,
    this.isPR = false,
  });

  SetDraft copyWith({
    double? weightKg,
    int? reps,
    int? rir,
    String? notes,
    bool? completed,
    bool? isPR,
  }) =>
      SetDraft(
        weightKg: weightKg ?? this.weightKg,
        reps: reps ?? this.reps,
        rir: rir ?? this.rir,
        notes: notes ?? this.notes,
        completed: completed ?? this.completed,
        isPR: isPR ?? this.isPR,
      );
}

class ActiveWorkoutState {
  final int sessionId;
  final Day day;
  /// exerciseId → lista de borradores (uno por serie objetivo)
  final Map<int, List<SetDraft>> drafts;
  final int? expandedExerciseId;
  final DateTime startTime;
  /// exerciseId → mejor peso de la última sesión (para autofill)
  final Map<int, double> lastWeightByExercise;
  /// exerciseId → mejor 1RM histórico (para detectar PR)
  final Map<int, double> best1RMByExercise;
  /// Temporizador de descanso
  final bool restTimerActive;
  final int restTimerRemaining; // segundos
  final int restTimerTotal;
  final int? restTimerExerciseId;
  final bool isFinished;

  const ActiveWorkoutState({
    required this.sessionId,
    required this.day,
    required this.drafts,
    this.expandedExerciseId,
    required this.startTime,
    this.lastWeightByExercise = const {},
    this.best1RMByExercise = const {},
    this.restTimerActive = false,
    this.restTimerRemaining = 0,
    this.restTimerTotal = 90,
    this.restTimerExerciseId,
    this.isFinished = false,
  });

  int get completedSets =>
      drafts.values.expand((l) => l).where((d) => d.completed).length;

  int get totalSets =>
      day.exercises.fold(0, (acc, e) => acc + e.targetSets);

  double get progressPercent =>
      totalSets == 0 ? 0 : completedSets / totalSets;

  bool hasPR(int exerciseId) =>
      drafts[exerciseId]?.any((d) => d.isPR) ?? false;

  ActiveWorkoutState copyWith({
    int? sessionId,
    Day? day,
    Map<int, List<SetDraft>>? drafts,
    int? expandedExerciseId,
    bool clearExpanded = false,
    DateTime? startTime,
    Map<int, double>? lastWeightByExercise,
    Map<int, double>? best1RMByExercise,
    bool? restTimerActive,
    int? restTimerRemaining,
    int? restTimerTotal,
    int? restTimerExerciseId,
    bool clearRestExercise = false,
    bool? isFinished,
  }) =>
      ActiveWorkoutState(
        sessionId: sessionId ?? this.sessionId,
        day: day ?? this.day,
        drafts: drafts ?? this.drafts,
        expandedExerciseId: clearExpanded
            ? null
            : (expandedExerciseId ?? this.expandedExerciseId),
        startTime: startTime ?? this.startTime,
        lastWeightByExercise:
            lastWeightByExercise ?? this.lastWeightByExercise,
        best1RMByExercise: best1RMByExercise ?? this.best1RMByExercise,
        restTimerActive: restTimerActive ?? this.restTimerActive,
        restTimerRemaining: restTimerRemaining ?? this.restTimerRemaining,
        restTimerTotal: restTimerTotal ?? this.restTimerTotal,
        restTimerExerciseId: clearRestExercise
            ? null
            : (restTimerExerciseId ?? this.restTimerExerciseId),
        isFinished: isFinished ?? this.isFinished,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────

class ActiveWorkoutNotifier
    extends StateNotifier<AsyncValue<ActiveWorkoutState>> {
  final IWorkoutRepository _workoutRepo;
  final IRoutineRepository _routineRepo;

  Timer? _restTimer;

  ActiveWorkoutNotifier(
    this._workoutRepo,
    this._routineRepo,
  ) : super(const AsyncValue.loading());

  // ── Inicialización ─────────────────────────────────────────────────────

  Future<void> init(int dayId) async {
    state = const AsyncValue.loading();
    try {
      final day = await _routineRepo.getDayWithExercises(dayId);
      if (day == null) throw Exception('Día no encontrado');

      // Carga pesos de la última sesión + mejor 1RM para cada ejercicio
      final lastWeight = <int, double>{};
      final best1RM = <int, double>{};

      for (final ex in day.exercises) {
        if (ex.id == null) continue;
        final logs = await _workoutRepo.getLastLogsForExercise(ex.id!);
        if (logs.isNotEmpty) {
          // Peso del último set completado
          final lastCompleted = logs.firstWhere(
            (l) => l.completed && l.weightKg > 0,
            orElse: () => logs.first,
          );
          lastWeight[ex.id!] = lastCompleted.weightKg;

          // Mejor 1RM histórico
          double maxOneRM = 0;
          for (final l in logs) {
            if (l.completed && l.weightKg > 0 && l.repsDone > 0) {
              final orm = CalculationUtils.estimate1RM(l.weightKg, l.repsDone);
              if (orm > maxOneRM) maxOneRM = orm;
            }
          }
          if (maxOneRM > 0) best1RM[ex.id!] = maxOneRM;
        }
      }

      // Crear sesión en la BD
      final session = WorkoutSession(
        dayId: dayId,
        date: DateTime.now(),
        completed: false,
      );
      final sessionId = await _workoutRepo.insertSession(session);

      // Inicializar borradores (una serie por set objetivo, prefilled)
      final drafts = <int, List<SetDraft>>{};
      for (final ex in day.exercises) {
        if (ex.id == null) continue;
        final prefill = lastWeight[ex.id!] ?? 0;
        drafts[ex.id!] = List.generate(
          ex.targetSets,
          (_) => SetDraft(weightKg: prefill),
        );
      }

      state = AsyncValue.data(ActiveWorkoutState(
        sessionId: sessionId,
        day: day,
        drafts: drafts,
        expandedExerciseId: day.exercises.isNotEmpty
            ? day.exercises.first.id
            : null,
        startTime: DateTime.now(),
        lastWeightByExercise: lastWeight,
        best1RMByExercise: best1RM,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Edición de series (sin guardar aún) ────────────────────────────────

  void updateDraft(int exerciseId, int setIndex,
      {double? weight, int? reps, int? rir, String? notes}) {
    final current = state.value;
    if (current == null) return;
    final list = List<SetDraft>.from(current.drafts[exerciseId] ?? []);
    if (setIndex >= list.length) return;
    list[setIndex] = list[setIndex].copyWith(
      weightKg: weight,
      reps: reps,
      rir: rir,
      notes: notes,
    );
    state = AsyncValue.data(current.copyWith(
      drafts: {...current.drafts, exerciseId: list},
    ));
  }

  // ── Completar serie ────────────────────────────────────────────────────

  Future<void> toggleSetComplete(
      int exerciseId, int setIndex, Exercise exercise) async {
    final current = state.value;
    if (current == null) return;

    final list = List<SetDraft>.from(current.drafts[exerciseId] ?? []);
    if (setIndex >= list.length) return;

    final draft = list[setIndex];
    final nowCompleted = !draft.completed;

    // Detectar PR: 1RM de esta serie vs mejor histórico
    bool isPR = false;
    if (nowCompleted && draft.weightKg > 0 && draft.reps > 0) {
      final orm = CalculationUtils.estimate1RM(draft.weightKg, draft.reps);
      final prev = current.best1RMByExercise[exerciseId] ?? 0;
      isPR = orm > prev;
      if (isPR) {
        // Actualizar best1RM en estado
        final updated = Map<int, double>.from(current.best1RMByExercise);
        updated[exerciseId] = orm;
        state = AsyncValue.data(current.copyWith(best1RMByExercise: updated));
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    }

    list[setIndex] = draft.copyWith(completed: nowCompleted, isPR: isPR);

    final updatedState = (state.value ?? current).copyWith(
      drafts: {
        ...(state.value ?? current).drafts,
        exerciseId: list,
      },
    );

    state = AsyncValue.data(updatedState);

    // Persistir set log en BD
    final log = SetLog(
      sessionId: current.sessionId,
      exerciseId: exerciseId,
      setNumber: setIndex + 1,
      weightKg: draft.weightKg,
      repsDone: draft.reps,
      rir: draft.rir,
      completed: nowCompleted,
      notes: draft.notes,
    );
    await _workoutRepo.insertSetLog(log);

    // Arrancar timer de descanso si se completó la serie
    if (nowCompleted) {
      _startRestTimer(exercise.restSeconds, exerciseId);
    } else {
      _cancelRestTimer();
    }
  }

  // ── Expansión de ejercicio ─────────────────────────────────────────────

  void expandExercise(int? exerciseId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(
      expandedExerciseId: exerciseId,
      clearExpanded: exerciseId == null,
    ));
  }

  // ── Swap de ejercicio ──────────────────────────────────────────────────

  Future<void> swapExercise({
    required Exercise original,
    required int substituteLibraryId,
    required String substituteName,
    required String substituteMuscle,
    required bool permanent,
    required String reason,
  }) async {
    final current = state.value;
    if (current == null || original.id == null) return;

    // Crear nuevo Exercise con mismos parámetros pero nombre/músculo del sustituto
    final newExercise = original.copyWith(
      name: substituteName,
      muscleGroup: substituteMuscle,
      libraryId: substituteLibraryId,
    );

    // Si permanente, actualizar en BD
    if (permanent) {
      await _routineRepo.updateExercise(newExercise);
    }

    // Registrar el swap
    final swap = ExerciseSwap(
      originalExerciseId: original.id!,
      substituteExerciseId: substituteLibraryId,
      sessionId: current.sessionId,
      date: DateTime.now(),
      reason: reason,
      isPermanent: permanent,
    );
    await _workoutRepo.insertExerciseSwap(swap);

    // Actualizar el día en estado
    final updatedExercises = current.day.exercises
        .map((e) => e.id == original.id ? newExercise : e)
        .toList();
    final updatedDay = current.day.copyWith(exercises: updatedExercises);

    // Migrar borradores al nuevo ejercicio (mismo ID, solo cambia nombre)
    state = AsyncValue.data(current.copyWith(day: updatedDay));
  }

  // ── Terminar entrenamiento ─────────────────────────────────────────────

  Future<void> finishWorkout({int? feeling, String notes = ''}) async {
    final current = state.value;
    if (current == null) return;

    _cancelRestTimer();

    final duration =
        DateTime.now().difference(current.startTime).inSeconds;
    final session = WorkoutSession(
      id: current.sessionId,
      dayId: current.day.id!,
      date: current.startTime,
      durationSeconds: duration,
      notes: notes,
      feeling: feeling,
      completed: true,
    );
    await _workoutRepo.updateSession(session);
    state = AsyncValue.data(current.copyWith(isFinished: true));
  }

  Future<void> abandonWorkout() async {
    final current = state.value;
    if (current == null) return;
    _cancelRestTimer();
    await _workoutRepo.deleteSession(current.sessionId);
    state = AsyncValue.data(current.copyWith(isFinished: true));
  }

  // ── Timer de descanso ──────────────────────────────────────────────────

  void _startRestTimer(int seconds, int exerciseId) {
    _cancelRestTimer();
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(
      restTimerActive: true,
      restTimerRemaining: seconds,
      restTimerTotal: seconds,
      restTimerExerciseId: exerciseId,
    ));

    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final s = state.value;
      if (s == null) {
        t.cancel();
        return;
      }
      final remaining = s.restTimerRemaining - 1;
      if (remaining <= 0) {
        t.cancel();
        HapticFeedback.heavyImpact();
        state = AsyncValue.data(s.copyWith(
          restTimerActive: false,
          restTimerRemaining: 0,
          clearRestExercise: true,
        ));
      } else {
        state = AsyncValue.data(
            s.copyWith(restTimerRemaining: remaining));
      }
    });
  }

  void cancelRestTimer() => _cancelRestTimer();

  void _cancelRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    final s = state.value;
    if (s != null && s.restTimerActive) {
      state = AsyncValue.data(s.copyWith(
        restTimerActive: false,
        restTimerRemaining: 0,
        clearRestExercise: true,
      ));
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final activeWorkoutProvider = StateNotifierProvider.autoDispose<
    ActiveWorkoutNotifier, AsyncValue<ActiveWorkoutState>>(
  (ref) => ActiveWorkoutNotifier(
    ref.watch(workoutRepositoryProvider),
    ref.watch(routineRepositoryProvider),
  ),
);
