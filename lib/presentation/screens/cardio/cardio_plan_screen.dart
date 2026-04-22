import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/cardio_week.dart';
import '../../../domain/entities/cardio_session_template.dart';
import '../../providers/cardio_provider.dart';
import 'active_cardio_screen.dart';

class CardioPlanScreen extends ConsumerWidget {
  const CardioPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cardioProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.white70)),
          ),
          data: (s) {
            if (s.plan == null) {
              return const Center(
                child: Text('No hay plan de cardio',
                    style: TextStyle(color: AppTheme.darkMuted)),
              );
            }
            return _PlanBody(state: s);
          },
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _PlanBody extends ConsumerWidget {
  final CardioState state;
  const _PlanBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = state.plan!;
    final globalPct = plan.globalProgress;

    return CustomScrollView(
      slivers: [
        // ── AppBar ─────────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.darkBg,
          title: const Text('Plan de Cardio'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${plan.completedSessions}/${plan.totalSessions} sesiones',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.darkMuted),
                      ),
                      Text(
                        '${(globalPct * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.cardioColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: globalPct,
                      minHeight: 6,
                      backgroundColor: AppTheme.darkBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.cardioColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Stats chips ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.local_fire_department_rounded,
                  label: '${state.cardioStreakDays} días',
                  sub: 'Racha',
                  color: AppTheme.gymColor,
                ),
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.directions_run_rounded,
                  label: '${state.sessionsThisWeek} sesiones',
                  sub: 'Esta semana',
                  color: AppTheme.cardioColor,
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // ── Semanas ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _WeekTile(
                week: plan.weeks[i],
                isCurrentWeek: plan.weeks[i].weekNumber == plan.currentWeek,
              ),
              childCount: plan.weeks.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Semana tile ────────────────────────────────────────────────────────────────

class _WeekTile extends ConsumerStatefulWidget {
  final CardioWeek week;
  final bool isCurrentWeek;

  const _WeekTile({required this.week, required this.isCurrentWeek});

  @override
  ConsumerState<_WeekTile> createState() => _WeekTileState();
}

class _WeekTileState extends ConsumerState<_WeekTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isCurrentWeek;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.week;
    final pct = w.progressPercent;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Week badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: w.isComplete
                          ? AppTheme.cardioColor.withValues(alpha: 0.2)
                          : widget.isCurrentWeek
                              ? AppTheme.primary.withValues(alpha: 0.2)
                              : AppTheme.darkBorder,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: w.isComplete
                          ? const Icon(Icons.check_rounded,
                              color: AppTheme.cardioColor, size: 22)
                          : Text(
                              'S${w.weekNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.isCurrentWeek
                                    ? AppTheme.primary
                                    : AppTheme.darkMuted,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Semana ${w.weekNumber}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                            if (widget.isCurrentWeek) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('ACTUAL',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8)),
                              ),
                            ],
                          ],
                        ),
                        if (w.objective.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(w.objective,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.darkMuted)),
                        ],
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 4,
                            backgroundColor: AppTheme.darkBorder,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppTheme.cardioColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${w.completedSessions}/${w.targetSessions}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.darkMuted)),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.darkMuted),
                  ),
                ],
              ),
            ),
          ),

          // Sessions
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1, indent: 16, endIndent: 16),
                ...w.sessions.map((s) => _SessionTile(session: s)),
                const SizedBox(height: 8),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ── Session tile ──────────────────────────────────────────────────────────────

class _SessionTile extends ConsumerWidget {
  final CardioSessionTemplate session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeLabel = AppConstants.cardioTypeLabels[session.type] ??
        session.type;
    final color = _typeColor(session.type);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_typeIcon(session.type), color: color, size: 18),
      ),
      title: Text(session.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(
        '$typeLabel · ${session.estimatedDuration} min',
        style: const TextStyle(fontSize: 11, color: AppTheme.darkMuted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!session.completed)
            IconButton(
              icon: const Icon(Icons.play_circle_fill_rounded,
                  color: AppTheme.cardioColor, size: 28),
              onPressed: () => _startSession(context, session),
              padding: EdgeInsets.zero,
            ),
          Checkbox(
            value: session.completed,
            activeColor: AppTheme.cardioColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: session.id == null
                ? null
                : (v) => ref
                    .read(cardioProvider.notifier)
                    .markSession(session.id!, v ?? false),
          ),
        ],
      ),
    );
  }

  void _startSession(BuildContext context, CardioSessionTemplate s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveCardioScreen(session: s),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case AppConstants.cardioWalk:
        return Icons.directions_walk_rounded;
      case AppConstants.cardioWalkRun:
        return Icons.transfer_within_a_station_rounded;
      case AppConstants.cardioJog:
        return Icons.directions_run_rounded;
      case AppConstants.cardioHiit:
        return Icons.flash_on_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case AppConstants.cardioWalk:
        return const Color(0xFF64B5F6);
      case AppConstants.cardioWalkRun:
        return AppTheme.cardioColor;
      case AppConstants.cardioJog:
        return AppTheme.gymColor;
      case AppConstants.cardioHiit:
        return AppTheme.prColor;
      default:
        return AppTheme.primary;
    }
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

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
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
