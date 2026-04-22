import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/reminder.dart';
import '../../providers/reminder_provider.dart';

class ReminderEditSheet extends ConsumerStatefulWidget {
  final Reminder? existing;
  const ReminderEditSheet({super.key, this.existing});

  @override
  ConsumerState<ReminderEditSheet> createState() => _ReminderEditSheetState();
}

class _ReminderEditSheetState extends ConsumerState<ReminderEditSheet> {
  late String _type;
  late String _personality;
  late int _daysBitmask;
  late TimeOfDay _time;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _type = r?.type ?? AppConstants.reminderGym;
    _personality = r?.personality ?? AppConstants.personalityMotivational;
    _daysBitmask = r?.activeDaysBitmask ?? AppConstants.dayAllWeek;
    _isActive = r?.isActive ?? true;
    if (r != null) {
      final parts = r.scheduledTime.split(':');
      _time =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else {
      _time = const TimeOfDay(hour: 7, minute: 0);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final timeStr =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    final notifier = ref.read(reminderProvider.notifier);

    if (widget.existing == null) {
      await notifier.addReminder(Reminder(
        type: _type,
        scheduledTime: timeStr,
        activeDaysBitmask: _daysBitmask,
        isActive: _isActive,
        personality: _personality,
      ));
    } else {
      await notifier.updateReminder(widget.existing!.copyWith(
        type: _type,
        scheduledTime: timeStr,
        activeDaysBitmask: _daysBitmask,
        isActive: _isActive,
        personality: _personality,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isNew ? 'Nuevo recordatorio' : 'Editar recordatorio',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // ── Tipo ──────────────────────────────────────────────────
            const _SectionLabel('Tipo'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppConstants.reminderGym,
                AppConstants.reminderCardio,
                AppConstants.reminderWeigh,
                AppConstants.reminderMotivational,
              ].map((t) => _ChoiceChip(
                    label: _typeLabel(t),
                    selected: _type == t,
                    onTap: () => setState(() => _type = t),
                    color: _typeColor(t),
                  )).toList(),
            ),

            const SizedBox(height: 20),

            // ── Hora ──────────────────────────────────────────────────
            const _SectionLabel('Hora'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF252540),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppTheme.darkMuted, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _time.format(context),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_rounded,
                        color: AppTheme.darkMuted, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Días ──────────────────────────────────────────────────
            const _SectionLabel('Días activos'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final bit = 1 << i;
                final selected = _daysBitmask & bit != 0;
                const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        // Keep at least 1 day active
                        if (_daysBitmask.bitCount > 1) {
                          _daysBitmask ^= bit;
                        }
                      } else {
                        _daysBitmask |= bit;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.darkBorder,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : AppTheme.darkMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ── Personalidad ──────────────────────────────────────────
            const _SectionLabel('Personalidad del mensaje'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.allPersonalities
                  .map((p) => _ChoiceChip(
                        label:
                            AppConstants.personalityLabels[p] ?? p,
                        selected: _personality == p,
                        onTap: () =>
                            setState(() => _personality = p),
                        color: _personalityColor(p),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // ── Activo ────────────────────────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Text('Recordatorio activo',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(isNew ? 'Crear' : 'Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case AppConstants.reminderGym:
        return 'Entrenamiento';
      case AppConstants.reminderCardio:
        return 'Cardio';
      case AppConstants.reminderWeigh:
        return 'Pesaje';
      default:
        return 'Motivación';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case AppConstants.reminderGym:
        return AppTheme.primary;
      case AppConstants.reminderCardio:
        return AppTheme.cardioColor;
      case AppConstants.reminderWeigh:
        return AppTheme.secondary;
      default:
        return AppTheme.gymColor;
    }
  }

  Color _personalityColor(String p) {
    switch (p) {
      case AppConstants.personalityEpic:
        return AppTheme.prColor;
      case AppConstants.personalitySarcastic:
        return AppTheme.gymColor;
      case AppConstants.personalityMotivational:
        return AppTheme.primary;
      case AppConstants.personalityFriendly:
        return AppTheme.cardioColor;
      case AppConstants.personalityMilitary:
        return AppTheme.errorColor;
      default:
        return AppTheme.darkMuted;
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

extension on int {
  int get bitCount {
    var n = this;
    var count = 0;
    while (n != 0) {
      count += n & 1;
      n >>= 1;
    }
    return count;
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5),
      );
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.2)
              : AppTheme.darkBorder,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? color : AppTheme.darkMuted,
          ),
        ),
      ),
    );
  }
}
