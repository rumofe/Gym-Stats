import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/day.dart';
import '../../domain/entities/workout_session.dart';
import '../providers/home_provider.dart';
import 'workout/active_workout_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: homeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: Colors.white70))),
          data: (s) => RefreshIndicator(
            onRefresh: () =>
                ref.read(homeProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Cabecera ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                              color: AppTheme.darkMuted, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.formatFull(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Stats rápidas ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _StatChip(
                          icon: Icons.local_fire_department_rounded,
                          label: '${s.streak} días',
                          sub: 'Racha',
                          color: AppTheme.gymColor,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          icon: Icons.calendar_today_rounded,
                          label: '${s.sessionsThisWeek} sesiones',
                          sub: 'Esta semana',
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Día sugerido + botón ───────────────────────────────
                if (s.suggestedDay != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _TodayCard(
                        day: s.suggestedDay!,
                        lastSession: s.lastSession,
                        onStart: () => _startWorkout(
                            context, ref, s.suggestedDay!),
                      ),
                    ),
                  ),

                // ── Días de la rutina ──────────────────────────────────
                if (s.routine != null) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text(
                        'Días de la rutina',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final day = s.routine!.days[i];
                          final isSuggested =
                              day.id == s.suggestedDay?.id;
                          return _DayTile(
                            day: day,
                            isSuggested: isSuggested,
                            onTap: () =>
                                _startWorkout(context, ref, day),
                          );
                        },
                        childCount: s.routine!.days.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startWorkout(
      BuildContext context, WidgetRef ref, Day day) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          dayId: day.id!,
          dayName: day.name,
        ),
      ),
    );
    if (result == true) {
      ref.read(homeProvider.notifier).refresh();
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 13) return 'Buenos días 👋';
    if (h < 20) return 'Buenas tardes 👋';
    return 'Buenas noches 👋';
  }
}

// ── Tarjeta "Hoy" ─────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  final Day day;
  final WorkoutSession? lastSession;
  final VoidCallback onStart;

  const _TodayCard(
      {required this.day,
      required this.lastSession,
      required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.3),
            AppTheme.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('HOY TOCA',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            day.name,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '${day.exercises.length} ejercicios',
            style: const TextStyle(
                fontSize: 14, color: AppTheme.darkMuted),
          ),
          if (lastSession != null) ...[
            const SizedBox(height: 4),
            Text(
              'Último: ${AppDateUtils.formatShort(lastSession!.date)}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.darkMuted),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Empezar entrenamiento'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tile de día ────────────────────────────────────────────────────────────────

class _DayTile extends StatelessWidget {
  final Day day;
  final bool isSuggested;
  final VoidCallback onTap;

  const _DayTile(
      {required this.day,
      required this.isSuggested,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isSuggested
                ? AppTheme.primary.withValues(alpha: 0.2)
                : AppTheme.darkBorder,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.fitness_center_rounded,
              color: isSuggested
                  ? AppTheme.primary
                  : AppTheme.darkMuted,
              size: 20),
        ),
        title: Text(day.name,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSuggested ? Colors.white : Colors.white70)),
        subtitle: Text(
          '${day.exercises.length} ejercicios',
          style: const TextStyle(fontSize: 12, color: AppTheme.darkMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSuggested)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Siguiente',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600)),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.darkMuted),
          ],
        ),
      ),
    );
  }
}

// ── Chip de estadística ───────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;

  const _StatChip(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.darkMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
