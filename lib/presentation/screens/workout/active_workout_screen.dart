import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../providers/active_workout_provider.dart';
import '../../widgets/workout/exercise_card.dart';
import '../../widgets/workout/rest_timer_widget.dart';
import '../../widgets/workout/exercise_swap_sheet.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final int dayId;
  final String dayName;

  const ActiveWorkoutScreen({
    super.key,
    required this.dayId,
    required this.dayName,
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  // Temporizador de duración total del entrenamiento (mostrado en AppBar)
  late final _elapsedNotifier = ValueNotifier<int>(0);
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeWorkoutProvider.notifier).init(widget.dayId);
    });
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _startTime = DateTime.now();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      _elapsedNotifier.value =
          DateTime.now().difference(_startTime!).inSeconds;
      return true;
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _elapsedNotifier.dispose();
    super.dispose();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  void _onSwapExercise(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExerciseSwapSheet(
        originalExercise: exercise,
        onConfirm: ({
          required substituteLibraryId,
          required substituteName,
          required substituteMuscle,
          required permanent,
          required reason,
        }) {
          ref.read(activeWorkoutProvider.notifier).swapExercise(
                original: exercise,
                substituteLibraryId: substituteLibraryId,
                substituteName: substituteName,
                substituteMuscle: substituteMuscle,
                permanent: permanent,
                reason: reason,
              );
        },
      ),
    );
  }

  Future<void> _onFinishWorkout(BuildContext context) async {
    final result = await showDialog<_FinishResult?>(
      context: context,
      builder: (_) => const _FinishWorkoutDialog(),
    );
    if (result == null || !context.mounted) return;
    if (result.abandon) {
      await ref.read(activeWorkoutProvider.notifier).abandonWorkout();
    } else {
      await ref.read(activeWorkoutProvider.notifier).finishWorkout(
            feeling: result.feeling,
            notes: result.notes,
          );
    }
    if (context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final workoutAsync = ref.watch(activeWorkoutProvider);

    // Navegar fuera cuando el workout termina
    ref.listen<AsyncValue<ActiveWorkoutState>>(activeWorkoutProvider,
        (_, next) {
      if (next.value?.isFinished == true) {
        Navigator.of(context).pop(true);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onFinishWorkout(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: workoutAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.errorColor, size: 48),
                const SizedBox(height: 12),
                Text('Error al cargar: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ]),
            ),
          ),
          data: (s) => _WorkoutBody(
            workoutState: s,
            elapsedNotifier: _elapsedNotifier,
            onSwapExercise: (ex) => _onSwapExercise(context, ex),
            onFinish: () => _onFinishWorkout(context),
            onExpandExercise: (id) =>
                ref.read(activeWorkoutProvider.notifier).expandExercise(id),
            onDraftChanged: (exId, idx, draft) =>
                ref.read(activeWorkoutProvider.notifier).updateDraft(
                      exId,
                      idx,
                      weight: draft.weightKg,
                      reps: draft.reps,
                      rir: draft.rir,
                      notes: draft.notes,
                    ),
            onToggleSet: (exId, idx, ex) => ref
                .read(activeWorkoutProvider.notifier)
                .toggleSetComplete(exId, idx, ex),
            onSkipRest: () =>
                ref.read(activeWorkoutProvider.notifier).cancelRestTimer(),
          ),
        ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _WorkoutBody extends StatelessWidget {
  final ActiveWorkoutState workoutState;
  final ValueNotifier<int> elapsedNotifier;
  final void Function(Exercise) onSwapExercise;
  final VoidCallback onFinish;
  final void Function(int?) onExpandExercise;
  final void Function(int exId, int idx, SetDraft draft) onDraftChanged;
  final void Function(int exId, int idx, Exercise ex) onToggleSet;
  final VoidCallback onSkipRest;

  const _WorkoutBody({
    required this.workoutState,
    required this.elapsedNotifier,
    required this.onSwapExercise,
    required this.onFinish,
    required this.onExpandExercise,
    required this.onDraftChanged,
    required this.onToggleSet,
    required this.onSkipRest,
  });

  @override
  Widget build(BuildContext context) {
    final s = workoutState;
    return CustomScrollView(
      slivers: [
        // ── AppBar ────────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.darkBg,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.day.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              ValueListenableBuilder<int>(
                valueListenable: elapsedNotifier,
                builder: (context2, elapsed, child) => Text(
                  AppDateUtils.formatChrono(elapsed),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkMuted,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          actions: [
            // Progreso compacto
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '${s.completedSets}/${s.totalSets}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkMuted),
                ),
              ),
            ),
            // Botón terminar
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: onFinish,
                style: FilledButton.styleFrom(
                  backgroundColor: s.completedSets == s.totalSets
                      ? AppTheme.primary
                      : AppTheme.gymColor,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: Text(s.completedSets == s.totalSets
                    ? '¡Listo! 🎉'
                    : 'Terminar'),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: _ProgressBar(
                progress: s.progressPercent,
                allDone: s.completedSets == s.totalSets),
          ),
        ),

        // ── Timer de descanso ─────────────────────────────────────────
        if (s.restTimerActive)
          SliverToBoxAdapter(
            child: RestTimerBanner(
              remainingSeconds: s.restTimerRemaining,
              totalSeconds: s.restTimerTotal,
              onSkip: onSkipRest,
            ),
          ),

        // ── Lista de ejercicios ───────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final exercise = s.day.exercises[i];
                if (exercise.id == null) return const SizedBox.shrink();
                final drafts = s.drafts[exercise.id!] ?? [];
                return ExerciseCard(
                  exercise: exercise,
                  drafts: drafts,
                  isExpanded: s.expandedExerciseId == exercise.id,
                  hasPR: s.hasPR(exercise.id!),
                  useKg: true,
                  onTapHeader: () => onExpandExercise(
                    s.expandedExerciseId == exercise.id
                        ? null
                        : exercise.id,
                  ),
                  onDraftChanged: (idx, draft) =>
                      onDraftChanged(exercise.id!, idx, draft),
                  onToggleComplete: (idx) =>
                      onToggleSet(exercise.id!, idx, exercise),
                  onSwap: () => onSwapExercise(exercise),
                );
              },
              childCount: s.day.exercises.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Barra de progreso ─────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double progress;
  final bool allDone;

  const _ProgressBar({required this.progress, required this.allDone});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppTheme.darkBorder,
        valueColor: AlwaysStoppedAnimation<Color>(
          allDone ? AppTheme.primary : AppTheme.gymColor,
        ),
      ),
    );
  }
}

// ── Diálogo de fin de entrenamiento ──────────────────────────────────────────

class _FinishResult {
  final int? feeling;
  final String notes;
  final bool abandon;
  const _FinishResult(
      {this.feeling, this.notes = '', this.abandon = false});
}

class _FinishWorkoutDialog extends StatefulWidget {
  const _FinishWorkoutDialog();

  @override
  State<_FinishWorkoutDialog> createState() => _FinishWorkoutDialogState();
}

class _FinishWorkoutDialogState extends State<_FinishWorkoutDialog> {
  int? _feeling;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkCard,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Terminar entrenamiento?',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('¿Cómo te has sentido?',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.darkMuted)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final val = i + 1;
                final emojis = ['😵', '😓', '😐', '💪', '🔥'];
                final selected = _feeling == val;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _feeling = val);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : AppTheme.darkBorder,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(emojis[i],
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                hintText: 'Notas del entrenamiento (opcional)…',
                isDense: true,
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Abandonar
                TextButton(
                  onPressed: () => Navigator.pop(
                      context,
                      const _FinishResult(abandon: true)),
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor),
                  child: const Text('Abandonar'),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continuar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _FinishResult(
                      feeling: _feeling,
                      notes: _notesCtrl.text,
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
