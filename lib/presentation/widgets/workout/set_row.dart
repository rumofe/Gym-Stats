import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/exercise.dart';
import '../../providers/active_workout_provider.dart';
import '../common/numeric_input.dart';

class SetRow extends StatefulWidget {
  final int setIndex;
  final Exercise exercise;
  final SetDraft draft;
  final bool useKg;
  final ValueChanged<SetDraft> onChanged;
  final VoidCallback onToggleComplete;

  const SetRow({
    super.key,
    required this.setIndex,
    required this.exercise,
    required this.draft,
    required this.useKg,
    required this.onChanged,
    required this.onToggleComplete,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow>
    with SingleTickerProviderStateMixin {
  bool _showNotes = false;
  late TextEditingController _notesCtrl;
  late AnimationController _prAnim;
  late Animation<double> _prScale;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.draft.notes);
    _prAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _prScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _prAnim, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(SetRow old) {
    super.didUpdateWidget(old);
    if (!old.draft.isPR && widget.draft.isPR) {
      _prAnim.forward(from: 0);
    }
    if (!_notesCtrl.text.isEqualToIgnoreCase(widget.draft.notes)) {
      _notesCtrl.text = widget.draft.notes;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _prAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.draft.completed;
    final isPR = widget.draft.isPR;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted
            ? (isPR
                ? AppTheme.prColor.withValues(alpha: 0.12)
                : AppTheme.primary.withValues(alpha: 0.10))
            : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? (isPR ? AppTheme.prColor.withValues(alpha: 0.5) : AppTheme.primary.withValues(alpha: 0.3))
              : AppTheme.darkBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Número de serie
                _SetBadge(
                    number: widget.setIndex + 1,
                    isCompleted: isCompleted),
                const SizedBox(width: 8),
                // Peso
                Expanded(
                  flex: 5,
                  child: NumericInput(
                    value: widget.draft.weightKg,
                    step: 2.5,
                    decimalPlaces: 1,
                    unit: widget.useKg ? 'kg' : 'lb',
                    onChanged: (v) =>
                        widget.onChanged(widget.draft.copyWith(weightKg: v)),
                    compact: true,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('×',
                    style: TextStyle(
                        color: AppTheme.darkMuted, fontSize: 16)),
                const SizedBox(width: 6),
                // Reps
                Expanded(
                  flex: 4,
                  child: NumericInput(
                    value: widget.draft.reps.toDouble(),
                    step: 1,
                    unit: 'reps',
                    onChanged: (v) => widget.onChanged(
                        widget.draft.copyWith(reps: v.toInt())),
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                // PR badge
                if (isPR)
                  ScaleTransition(
                    scale: _prScale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.prColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('PR',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black)),
                    ),
                  )
                else
                  const SizedBox(width: 30),
                const SizedBox(width: 6),
                // Botón notas
                GestureDetector(
                  onTap: () => setState(() => _showNotes = !_showNotes),
                  child: Icon(
                    Icons.notes_rounded,
                    size: 18,
                    color: widget.draft.notes.isNotEmpty
                        ? AppTheme.secondary
                        : AppTheme.darkMuted,
                  ),
                ),
                const SizedBox(width: 8),
                // Checkbox completar
                GestureDetector(
                  onTap: widget.onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isCompleted
                              ? AppTheme.primary
                              : AppTheme.darkMuted,
                          width: 2),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          // Campo de notas rápidas (expandible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                controller: _notesCtrl,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Nota rápida… (técnica, sensación…)',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onChanged: (v) =>
                    widget.onChanged(widget.draft.copyWith(notes: v)),
              ),
            ),
            crossFadeState: _showNotes
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _SetBadge extends StatelessWidget {
  final int number;
  final bool isCompleted;

  const _SetBadge({required this.number, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.primary.withValues(alpha: 0.2)
            : AppTheme.darkBorder,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isCompleted ? AppTheme.primary : AppTheme.darkMuted,
          ),
        ),
      ),
    );
  }
}

extension on String {
  bool isEqualToIgnoreCase(String other) =>
      toLowerCase() == other.toLowerCase();
}
