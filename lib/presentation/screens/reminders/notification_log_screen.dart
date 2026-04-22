import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/notification_log.dart';
import '../../providers/reminder_provider.dart';

class NotificationLogScreen extends ConsumerWidget {
  final List<NotificationLog> logs;
  const NotificationLogScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Historial de mensajes'),
      ),
      body: logs.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      color: AppTheme.darkMuted, size: 56),
                  SizedBox(height: 16),
                  Text('Sin mensajes registrados',
                      style: TextStyle(color: AppTheme.darkMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: logs.length,
              itemBuilder: (ctx, i) => _LogTile(
                log: logs[i],
                onFavorite: () =>
                    ref.read(reminderProvider.notifier).markFavorite(logs[i]),
                onBlacklist: () => ref
                    .read(reminderProvider.notifier)
                    .blacklistMessage(logs[i]),
              ),
            ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final NotificationLog log;
  final VoidCallback onFavorite;
  final VoidCallback onBlacklist;

  const _LogTile({
    required this.log,
    required this.onFavorite,
    required this.onBlacklist,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = log.interaction == NotificationLog.interactionFavorite;
    final isBlacklisted =
        log.interaction == NotificationLog.interactionBlacklist;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isBlacklisted
                          ? AppTheme.darkMuted
                          : Colors.white,
                      decoration: isBlacklisted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppDateUtils.formatMed(log.sentAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.darkMuted),
                  ),
                ],
              ),
            ),
            if (!isBlacklisted) ...[
              IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 20,
                  color: isFav ? AppTheme.prColor : AppTheme.darkMuted,
                ),
                onPressed: isFav ? null : onFavorite,
                tooltip: 'Marcar como favorito',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.block_rounded,
                    size: 20, color: AppTheme.darkMuted),
                onPressed: onBlacklist,
                tooltip: 'No mostrar más',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
