import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/cardio_session_log.dart';
import '../../../domain/entities/cardio_session_template.dart';
import '../../providers/cardio_provider.dart';

// ── Interval definition ───────────────────────────────────────────────────────

class _Interval {
  final String label;
  final int seconds;
  final Color color;
  const _Interval(this.label, this.seconds, this.color);
}

List<_Interval> _buildIntervals(CardioSessionTemplate session) {
  if (session.type != AppConstants.cardioWalkRun &&
      session.type != AppConstants.cardioHiit) {
    return [];
  }

  final desc = session.description.toLowerCase();

  // Parse "X min run / Y min walk" from description
  final runMatch = RegExp(r'(\d+)\s*min[^/]*trot').firstMatch(desc);
  final walkMatch = RegExp(r'(\d+)\s*min[^/]*camin').firstMatch(desc);

  int runSecs = 60;
  int walkSecs = 120;

  if (runMatch != null) runSecs = int.parse(runMatch.group(1)!) * 60;
  if (walkMatch != null) walkSecs = int.parse(walkMatch.group(1)!) * 60;

  if (session.type == AppConstants.cardioHiit) {
    runSecs = 30;
    walkSecs = 90;
  }

  final totalSecs = session.estimatedDuration * 60;
  final cycleSecs = runSecs + walkSecs;
  final cycles = (totalSecs / cycleSecs).ceil();

  final intervals = <_Interval>[];
  for (var i = 0; i < cycles; i++) {
    intervals.add(_Interval('Trota', runSecs, AppTheme.gymColor));
    intervals.add(_Interval('Camina', walkSecs, const Color(0xFF64B5F6)));
  }
  return intervals;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ActiveCardioScreen extends ConsumerStatefulWidget {
  final CardioSessionTemplate session;

  const ActiveCardioScreen({super.key, required this.session});

  @override
  ConsumerState<ActiveCardioScreen> createState() => _ActiveCardioScreenState();
}

class _ActiveCardioScreenState extends ConsumerState<ActiveCardioScreen>
    with TickerProviderStateMixin {
  // Elapsed timer
  int _elapsedSecs = 0;
  Timer? _elapsedTimer;

  // Interval timer
  late final List<_Interval> _intervals;
  int _intervalIndex = 0;
  int _intervalRemaining = 0;
  Timer? _intervalTimer;

  // Animation for interval ring
  late AnimationController _ringController;

  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _intervals = _buildIntervals(widget.session);
    if (_intervals.isNotEmpty) {
      _intervalRemaining = _intervals[0].seconds;
    }
    _ringController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _intervals.isNotEmpty ? _intervals[0].seconds : 1),
    );
    _start();
  }

  void _start() {
    setState(() => _isRunning = true);

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSecs++);
    });

    if (_intervals.isNotEmpty) {
      _ringController.duration =
          Duration(seconds: _intervals[_intervalIndex].seconds);
      _ringController.forward(from: 0);
      _intervalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _intervalRemaining--;
          if (_intervalRemaining <= 0) {
            _advanceInterval();
          }
        });
      });
    }
  }

  void _advanceInterval() {
    HapticFeedback.mediumImpact();
    _intervalIndex = (_intervalIndex + 1) % _intervals.length;
    _intervalRemaining = _intervals[_intervalIndex].seconds;
    _ringController.duration =
        Duration(seconds: _intervals[_intervalIndex].seconds);
    _ringController.forward(from: 0);
  }

  void _togglePause() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsedSecs++);
      });
      if (_intervals.isNotEmpty) {
        _intervalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            _intervalRemaining--;
            if (_intervalRemaining <= 0) _advanceInterval();
          });
        });
        _ringController.forward();
      }
    } else {
      _elapsedTimer?.cancel();
      _intervalTimer?.cancel();
      _ringController.stop();
    }
  }

  void _finish() {
    _elapsedTimer?.cancel();
    _intervalTimer?.cancel();
    _showLogDialog();
  }

  Future<void> _showLogDialog() async {
    final log = await showModalBottomSheet<CardioSessionLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CardioLogSheet(
        session: widget.session,
        elapsedMinutes: (_elapsedSecs / 60).ceil(),
      ),
    );

    if (log != null && mounted) {
      await ref.read(cardioProvider.notifier).saveLog(log);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _intervalTimer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final hasIntervals = _intervals.isNotEmpty;
    final currentInterval = hasIntervals ? _intervals[_intervalIndex] : null;
    final typeLabel =
        AppConstants.cardioTypeLabels[session.type] ?? session.type;

    // Zone 2 HR (use default age 30 if not set)
    final z2 = CalculationUtils.zone2(30);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.darkCard,
            title: const Text('¿Salir?'),
            content: const Text(
                'Se perderá el progreso de esta sesión.',
                style: TextStyle(color: AppTheme.darkMuted)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Continuar')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Salir')),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBg,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              Text(typeLabel,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.darkMuted)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _finish,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.cardioColor,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Terminar'),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Elapsed timer ────────────────────────────────────────
              Text(
                AppDateUtils.formatChrono(_elapsedSecs),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              Text(
                'de ${session.estimatedDuration} min estimados',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.darkMuted),
              ),

              const SizedBox(height: 32),

              // ── Interval ring ────────────────────────────────────────
              if (hasIntervals && currentInterval != null)
                _IntervalRing(
                  label: currentInterval.label,
                  color: currentInterval.color,
                  remainingSecs: _intervalRemaining,
                  totalSecs: _intervals[_intervalIndex].seconds,
                  nextLabel: _intervals[
                          (_intervalIndex + 1) % _intervals.length]
                      .label,
                  controller: _ringController,
                )
              else
                _SimpleIcon(type: session.type),

              const SizedBox(height: 32),

              // ── Zone 2 ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: Color(0xFFEF5350), size: 20),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        const Text('Zona 2 (objetivo)',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.darkMuted)),
                        Text(
                          '${z2.low}–${z2.high} ppm',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF5350),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────
              if (session.description.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Text(
                    session.description,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.darkMuted, height: 1.5),
                  ),
                ),

              const Spacer(),

              // ── Pause / Resume ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppTheme.darkBorder, width: 2),
                    ),
                    child: Icon(
                      _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Interval ring widget ──────────────────────────────────────────────────────

class _IntervalRing extends StatelessWidget {
  final String label;
  final Color color;
  final int remainingSecs;
  final int totalSecs;
  final String nextLabel;
  final AnimationController controller;

  const _IntervalRing({
    required this.label,
    required this.color,
    required this.remainingSecs,
    required this.totalSecs,
    required this.nextLabel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSecs > 0 ? remainingSecs / totalSecs : 0.0;
    final mins = remainingSecs ~/ 60;
    final secs = remainingSecs % 60;

    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context2, child) => CustomPaint(
                    painter: _RingPainter(
                      progress: progress,
                      color: color,
                      backgroundColor: AppTheme.darkBorder,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Siguiente: $nextLabel',
          style: const TextStyle(fontSize: 12, color: AppTheme.darkMuted),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Simple icon for non-interval types ───────────────────────────────────────

class _SimpleIcon extends StatelessWidget {
  final String type;
  const _SimpleIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = type == AppConstants.cardioWalk
        ? Icons.directions_walk_rounded
        : Icons.directions_run_rounded;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.cardioColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppTheme.cardioColor, size: 56),
    );
  }
}

// ── Log sheet ─────────────────────────────────────────────────────────────────

class _CardioLogSheet extends StatefulWidget {
  final CardioSessionTemplate session;
  final int elapsedMinutes;

  const _CardioLogSheet({
    required this.session,
    required this.elapsedMinutes,
  });

  @override
  State<_CardioLogSheet> createState() => _CardioLogSheetState();
}

class _CardioLogSheetState extends State<_CardioLogSheet> {
  late final TextEditingController _durationCtrl;
  final _distanceCtrl = TextEditingController();
  final _avgHrCtrl = TextEditingController();
  final _maxHrCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int? _feeling;

  @override
  void initState() {
    super.initState();
    _durationCtrl =
        TextEditingController(text: widget.elapsedMinutes.toString());
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    _avgHrCtrl.dispose();
    _maxHrCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final duration = int.tryParse(_durationCtrl.text) ??
        widget.elapsedMinutes;

    final log = CardioSessionLog(
      templateId: widget.session.id!,
      date: DateTime.now(),
      realDuration: duration,
      distance: double.tryParse(_distanceCtrl.text),
      avgHr: int.tryParse(_avgHrCtrl.text),
      maxHr: int.tryParse(_maxHrCtrl.text),
      feeling: _feeling,
      notes: _notesCtrl.text,
    );
    Navigator.pop(context, log);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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

            const Text('Guardar sesión',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),

            const SizedBox(height: 20),

            // Duration + Distance
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duración (min)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _distanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Distancia (km)',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // HR fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _avgHrCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'FC media (ppm)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxHrCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'FC máx (ppm)',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Feeling
            const Text('¿Cómo ha ido?',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.darkMuted)),
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.cardioColor
                              .withValues(alpha: 0.2)
                          : AppTheme.darkBorder,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.cardioColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(emojis[i],
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                hintText: 'Notas (opcional)…',
                isDense: true,
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.cardioColor),
                child: const Text('Guardar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
