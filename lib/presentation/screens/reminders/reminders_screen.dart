import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/reminder.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_edit_sheet.dart';
import 'notification_log_screen.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reminderProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.white70)),
          ),
          data: (s) => CustomScrollView(
            slivers: [
              // ── AppBar ────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.darkBg,
                title: const Text('Recordatorios'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NotificationLogScreen(logs: s.recentLogs),
                      ),
                    ),
                    tooltip: 'Historial de mensajes',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () => _openEdit(context, ref, null),
                    tooltip: 'Nuevo recordatorio',
                  ),
                ],
              ),

              // ── List ──────────────────────────────────────────────────
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(12, 8, 12, 80),
                sliver: s.reminders.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              const Icon(Icons.notifications_off_rounded,
                                  color: AppTheme.darkMuted, size: 56),
                              const SizedBox(height: 16),
                              const Text('Sin recordatorios',
                                  style:
                                      TextStyle(color: AppTheme.darkMuted)),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                onPressed: () => _openEdit(context, ref, null),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Crear recordatorio'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _ReminderTile(
                            reminder: s.reminders[i],
                            onToggle: (v) => ref
                                .read(reminderProvider.notifier)
                                .toggle(s.reminders[i].id!, v),
                            onEdit: () =>
                                _openEdit(context, ref, s.reminders[i]),
                          ),
                          childCount: s.reminders.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit(
      BuildContext context, WidgetRef ref, Reminder? existing) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReminderEditSheet(existing: existing),
    );
  }
}

// ── Reminder tile ─────────────────────────────────────────────────────────────

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _ReminderTile({
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = _typeLabel(reminder.type);
    final personalityLabel =
        AppConstants.personalityLabels[reminder.personality] ??
            reminder.personality;
    final days = AppDateUtils.weekdaysFromBitmask(reminder.activeDaysBitmask);
    final daysStr = days.map((d) => d.substring(0, 3)).join(', ');
    final color = _typeColor(reminder.type);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: reminder.isActive
                      ? color.withValues(alpha: 0.2)
                      : AppTheme.darkBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _typeIcon(reminder.type),
                  color: reminder.isActive ? color : AppTheme.darkMuted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: reminder.isActive
                            ? Colors.white
                            : AppTheme.darkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${reminder.scheduledTime}  ·  $daysStr',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.darkMuted),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            personalityLabel,
                            style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isActive,
                onChanged: onToggle,
                activeThumbColor: color,
              ),
            ],
          ),
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
      case AppConstants.reminderMotivational:
        return 'Motivación';
      default:
        return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case AppConstants.reminderGym:
        return Icons.fitness_center_rounded;
      case AppConstants.reminderCardio:
        return Icons.directions_run_rounded;
      case AppConstants.reminderWeigh:
        return Icons.monitor_weight_outlined;
      default:
        return Icons.emoji_events_rounded;
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
}
