import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';

/// Banner de temporizador de descanso que aparece en la parte superior
/// de la pantalla cuando está activo.
class RestTimerBanner extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final VoidCallback onSkip;

  const RestTimerBanner({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onSkip,
  });

  Color get _timerColor {
    final ratio = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    if (ratio > 0.5) return AppTheme.secondary;
    if (ratio > 0.25) return Colors.orange;
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _timerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Icono
          Icon(Icons.timer_outlined, color: _timerColor, size: 20),
          const SizedBox(width: 10),
          // Label
          const Text('Descansando',
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.darkMuted,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          // Tiempo
          Text(
            AppDateUtils.formatChrono(remainingSeconds),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _timerColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          // Progress ring
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor:
                      AppTheme.darkBorder,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_timerColor),
                ),
                Text(
                  '${remainingSeconds}s',
                  style: TextStyle(
                      fontSize: 8,
                      color: _timerColor,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Botón saltar
          GestureDetector(
            onTap: onSkip,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Saltar',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo flotante grande para el timer de descanso (modo inmersivo).
class RestTimerDialog extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final VoidCallback onSkip;
  final VoidCallback onAddTime;

  const RestTimerDialog({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onSkip,
    required this.onAddTime,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    return Dialog(
      backgroundColor: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Descansando',
                style: TextStyle(
                    color: AppTheme.darkMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.darkBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.secondary),
                  ),
                  Text(
                    AppDateUtils.formatChrono(remainingSeconds),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onAddTime,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+30s'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onSkip,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Saltar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
