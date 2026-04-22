import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/day.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/workout_session.dart';
import 'providers.dart';

class HomeState {
  final Routine? routine;
  final Day? suggestedDay;
  final WorkoutSession? lastSession;
  final int sessionsThisWeek;
  final int streak;

  const HomeState({
    this.routine,
    this.suggestedDay,
    this.lastSession,
    this.sessionsThisWeek = 0,
    this.streak = 0,
  });
}

class HomeNotifier extends AutoDisposeAsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final routineRepo = ref.watch(routineRepositoryProvider);
    final workoutRepo = ref.watch(workoutRepositoryProvider);

    final routines = await routineRepo.getAllRoutines();
    if (routines.isEmpty) return const HomeState();

    final routine = await routineRepo.getRoutineWithDays(routines.first.id!);
    if (routine == null || routine.days.isEmpty) {
      return HomeState(routine: routine);
    }

    // Última sesión
    final recent = await workoutRepo.getRecentSessions(limit: 1);
    final lastSession = recent.isNotEmpty ? recent.first : null;

    // Sesiones esta semana
    final weekCount =
        await workoutRepo.countSessionsInWeek(AppDateUtils.today());

    // Racha
    final streak = await workoutRepo.getCurrentStreak();

    // Sugerir el día que toca según la última sesión
    final suggestedDay =
        _suggestDay(routine.days, lastSession, weekCount);

    return HomeState(
      routine: routine,
      suggestedDay: suggestedDay,
      lastSession: lastSession,
      sessionsThisWeek: weekCount,
      streak: streak,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Day? _suggestDay(
    List<Day> days,
    WorkoutSession? last,
    int sessionsThisWeek,
  ) {
    if (days.isEmpty) return null;
    if (last == null) return days.first;

    // Encontrar el índice del último día entrenado
    final lastIndex = days.indexWhere((d) => d.id == last.dayId);
    if (lastIndex == -1) return days.first;

    // Siguiente día en la rotación
    return days[(lastIndex + 1) % days.length];
  }
}

final homeProvider =
    AsyncNotifierProvider.autoDispose<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
