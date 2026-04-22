import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/exercise.dart';
import '../../providers/active_workout_provider.dart';
import 'set_row.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final List<SetDraft> drafts;
  final bool isExpanded;
  final bool hasPR;
  final bool useKg;
  final VoidCallback onTapHeader;
  final void Function(int setIndex, SetDraft updated) onDraftChanged;
  final void Function(int setIndex) onToggleComplete;
  final VoidCallback onSwap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.drafts,
    required this.isExpanded,
    required this.hasPR,
    required this.useKg,
    required this.onTapHeader,
    required this.onDraftChanged,
    required this.onToggleComplete,
    required this.onSwap,
  });

  int get _completedSets => drafts.where((d) => d.completed).length;
  bool get _allDone => _completedSets >= exercise.targetSets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          InkWell(
            onTap: onTapHeader,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Indicador de progreso circular
                  _ProgressRing(
                    completed: _completedSets,
                    total: exercise.targetSets,
                    allDone: _allDone,
                  ),
                  const SizedBox(width: 12),
                  // Nombre y detalles
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                exercise.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: _allDone
                                      ? Colors.white54
                                      : Colors.white,
                                  decoration: _allDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasPR) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.prColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('🏆 PR',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${exercise.targetSets}×${exercise.repRangeDisplay}  '
                          'RIR${exercise.rirTarget}  •  ${exercise.muscleGroup}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Contador de series
                  Text(
                    '$_completedSets/${exercise.targetSets}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _allDone ? AppTheme.primary : AppTheme.darkMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.darkMuted),
                  ),
                ],
              ),
            ),
          ),
          // ── Sets expandidos ──────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ExerciseBody(
              exercise: exercise,
              drafts: drafts,
              useKg: useKg,
              onDraftChanged: onDraftChanged,
              onToggleComplete: onToggleComplete,
              onSwap: onSwap,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBody extends StatelessWidget {
  final Exercise exercise;
  final List<SetDraft> drafts;
  final bool useKg;
  final void Function(int setIndex, SetDraft updated) onDraftChanged;
  final void Function(int setIndex) onToggleComplete;
  final VoidCallback onSwap;

  const _ExerciseBody({
    required this.exercise,
    required this.drafts,
    required this.useKg,
    required this.onDraftChanged,
    required this.onToggleComplete,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera de columnas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                const SizedBox(width: 34),
                Expanded(
                  flex: 5,
                  child: Text('Peso',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const SizedBox(width: 22),
                Expanded(
                  flex: 4,
                  child: Text('Reps',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const SizedBox(width: 80),
              ],
            ),
          ),
          // Filas de series
          ...List.generate(
            drafts.length,
            (i) => SetRow(
              setIndex: i,
              exercise: exercise,
              draft: drafts[i],
              useKg: useKg,
              onChanged: (updated) => onDraftChanged(i, updated),
              onToggleComplete: () => onToggleComplete(i),
            ),
          ),
          // Notas del ejercicio
          if (exercise.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 13, color: AppTheme.darkMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    exercise.notes,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.darkMuted),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          // Botón cambiar ejercicio
          OutlinedButton.icon(
            onPressed: onSwap,
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: const Text('Cambiar ejercicio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.darkMuted,
              side: const BorderSide(color: AppTheme.darkBorder),
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int completed;
  final int total;
  final bool allDone;

  const _ProgressRing(
      {required this.completed,
      required this.total,
      required this.allDone});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.5,
            backgroundColor: AppTheme.darkBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              allDone ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.5),
            ),
          ),
          Icon(
            allDone ? Icons.check_rounded : Icons.fitness_center_rounded,
            size: 16,
            color: allDone ? AppTheme.primary : AppTheme.darkMuted,
          ),
        ],
      ),
    );
  }
}
