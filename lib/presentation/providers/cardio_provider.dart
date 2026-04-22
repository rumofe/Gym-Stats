import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cardio_plan.dart';
import '../../domain/entities/cardio_session_log.dart';
import '../../domain/repositories/i_cardio_repository.dart';
import 'providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class CardioState {
  final CardioPlan? plan;
  final int cardioStreakDays;
  final int sessionsThisWeek;

  const CardioState({
    this.plan,
    this.cardioStreakDays = 0,
    this.sessionsThisWeek = 0,
  });

  CardioState copyWith({
    CardioPlan? plan,
    int? cardioStreakDays,
    int? sessionsThisWeek,
  }) =>
      CardioState(
        plan: plan ?? this.plan,
        cardioStreakDays: cardioStreakDays ?? this.cardioStreakDays,
        sessionsThisWeek: sessionsThisWeek ?? this.sessionsThisWeek,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CardioNotifier extends AsyncNotifier<CardioState> {
  ICardioRepository get _repo => ref.read(cardioRepositoryProvider);

  @override
  Future<CardioState> build() => _load();

  Future<CardioState> _load() async {
    final plan = await _repo.getActivePlan();
    if (plan == null) return const CardioState();

    final full = await _repo.getPlanWithWeeks(plan.id!);
    final streak = await _repo.getCurrentCardioStreak();
    final thisWeek = await _repo.countSessionsInWeek(DateTime.now());

    return CardioState(
      plan: full,
      cardioStreakDays: streak,
      sessionsThisWeek: thisWeek,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> markSession(int templateId, bool completed) async {
    await _repo.markSessionCompleted(templateId, completed);
    await refresh();
  }

  Future<void> saveLog(CardioSessionLog log) async {
    await _repo.insertLog(log);
    await _repo.markSessionCompleted(log.templateId, true);
    await refresh();
  }
}

final cardioProvider =
    AsyncNotifierProvider<CardioNotifier, CardioState>(CardioNotifier.new);
