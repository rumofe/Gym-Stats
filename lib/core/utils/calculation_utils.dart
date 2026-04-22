/// Cálculo de 1RM (Epley), volumen, FC máx/Zona 2, platos en barra y conversión de unidades.
class CalculationUtils {
  CalculationUtils._();

  // ── 1RM (Epley): weight × (1 + 0.0333 × reps) ───────────────────────────
  static double estimate1RM(double weightKg, int reps) {
    if (reps <= 0 || weightKg <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + 0.0333 * reps);
  }

  /// Porcentaje del 1RM para un número de reps dado.
  static double percentageFor1RM(int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return 1.0;
    return 1 / (1 + 0.0333 * reps);
  }

  /// Peso para un % del 1RM estimado.
  static double weightFromPercent(double oneRM, double percent) =>
      oneRM * percent;

  // ── Volumen ───────────────────────────────────────────────────────────────
  static double setVolume(double weightKg, int reps) => weightKg * reps;

  /// Volumen total de una lista de pares (peso, reps).
  static double totalVolume(List<({double weight, int reps})> sets) =>
      sets.fold(0.0, (acc, s) => acc + setVolume(s.weight, s.reps));

  // ── Frecuencia cardíaca ───────────────────────────────────────────────────
  static int maxHR(int age) => 220 - age;

  /// Zona 2: 60-70 % FC máx.
  static ({int low, int high}) zone2(int age) {
    final max = maxHR(age);
    return (low: (max * 0.60).round(), high: (max * 0.70).round());
  }

  // ── Platos en barra ───────────────────────────────────────────────────────
  /// Devuelve platos por lado necesarios para alcanzar [targetWeight].
  /// [availablePlates] debe estar ordenado de mayor a menor.
  static Map<double, int> calculatePlates({
    required double targetWeight,
    required double barWeight,
    required List<double> availablePlates,
  }) {
    final result = <double, int>{};
    double remaining = (targetWeight - barWeight) / 2;
    if (remaining <= 0) return result;

    final sorted = [...availablePlates]..sort((a, b) => b.compareTo(a));
    for (final plate in sorted) {
      if (remaining < 0.001) break;
      final count = (remaining / plate).floor();
      if (count > 0) {
        result[plate] = count;
        remaining -= count * plate;
        remaining = double.parse(remaining.toStringAsFixed(4));
      }
    }
    return result;
  }

  static double loadedBarWeight({
    required double barWeight,
    required Map<double, int> platesPerSide,
  }) {
    double total = barWeight;
    for (final e in platesPerSide.entries) {
      total += e.key * e.value * 2;
    }
    return total;
  }

  // ── Conversión de unidades ────────────────────────────────────────────────
  static double kgToLb(double kg) => kg * 2.20462;
  static double lbToKg(double lb) => lb / 2.20462;

  /// Redondea a múltiplo de [step] (útil para sugerir pesos: 2.5 kg).
  static double roundToStep(double value, double step) =>
      (value / step).round() * step;
}
