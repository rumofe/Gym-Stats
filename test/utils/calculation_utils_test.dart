import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/core/utils/calculation_utils.dart';

void main() {
  group('CalculationUtils', () {
    group('estimate1RM (Epley)', () {
      test('1 rep devuelve el mismo peso', () {
        expect(CalculationUtils.estimate1RM(100, 1), equals(100.0));
      });

      test('0 reps devuelve 0', () {
        expect(CalculationUtils.estimate1RM(100, 0), equals(0.0));
      });

      test('peso 0 devuelve 0', () {
        expect(CalculationUtils.estimate1RM(0, 10), equals(0.0));
      });

      test('100 kg × 5 reps ≈ 116.65 kg', () {
        final result = CalculationUtils.estimate1RM(100, 5);
        expect(result, closeTo(116.65, 0.1));
      });

      test('80 kg × 8 reps ≈ 101.28 kg', () {
        final result = CalculationUtils.estimate1RM(80, 8);
        expect(result, closeTo(101.28, 0.1));
      });

      test('resultado siempre mayor que el peso de entrada (reps > 1)', () {
        for (var reps = 2; reps <= 15; reps++) {
          expect(CalculationUtils.estimate1RM(100, reps), greaterThan(100));
        }
      });
    });

    group('setVolume', () {
      test('100 kg × 5 reps = 500', () {
        expect(CalculationUtils.setVolume(100, 5), equals(500.0));
      });

      test('peso 0 = 0', () {
        expect(CalculationUtils.setVolume(0, 10), equals(0.0));
      });
    });

    group('totalVolume', () {
      test('suma correcta de varias series', () {
        final sets = [
          (weight: 100.0, reps: 5),
          (weight: 100.0, reps: 4),
          (weight: 90.0, reps: 6),
        ];
        // 500 + 400 + 540 = 1440
        expect(CalculationUtils.totalVolume(sets), equals(1440.0));
      });

      test('lista vacía devuelve 0', () {
        expect(CalculationUtils.totalVolume([]), equals(0.0));
      });
    });

    group('maxHR y zone2', () {
      test('maxHR: 220 - edad', () {
        expect(CalculationUtils.maxHR(25), equals(195));
        expect(CalculationUtils.maxHR(30), equals(190));
        expect(CalculationUtils.maxHR(40), equals(180));
      });

      test('zone2 al 60-70% de FC máx', () {
        final z = CalculationUtils.zone2(30);
        expect(z.low, equals((190 * 0.6).round()));  // 114
        expect(z.high, equals((190 * 0.7).round())); // 133
      });
    });

    group('calculatePlates', () {
      const plates = [20.0, 15.0, 10.0, 5.0, 2.5, 1.25];

      test('100 kg con barra de 20 kg = 40 kg por lado = 2×20', () {
        final result = CalculationUtils.calculatePlates(
          targetWeight: 100,
          barWeight: 20,
          availablePlates: plates,
        );
        expect(result[20.0], equals(2));
        expect(result[15.0], isNull);
      });

      test('barra vacía devuelve mapa vacío', () {
        final result = CalculationUtils.calculatePlates(
          targetWeight: 20,
          barWeight: 20,
          availablePlates: plates,
        );
        expect(result.isEmpty, isTrue);
      });

      test('102.5 kg con barra 20 kg = 2×20 + 1×2.5 por lado', () {
        final result = CalculationUtils.calculatePlates(
          targetWeight: 102.5,
          barWeight: 20,
          availablePlates: plates,
        );
        expect(result[20.0], equals(2));
        expect(result[2.5], equals(1));
      });

      test('loadedBarWeight concuerda con targetWeight', () {
        final target = 102.5;
        final result = CalculationUtils.calculatePlates(
          targetWeight: target,
          barWeight: 20,
          availablePlates: plates,
        );
        final loaded = CalculationUtils.loadedBarWeight(
          barWeight: 20,
          platesPerSide: result,
        );
        expect(loaded, closeTo(target, 0.01));
      });
    });

    group('conversión de unidades', () {
      test('100 kg ≈ 220.46 lb', () {
        expect(CalculationUtils.kgToLb(100), closeTo(220.46, 0.01));
      });

      test('220.46 lb ≈ 100 kg', () {
        expect(CalculationUtils.lbToKg(220.46), closeTo(100, 0.01));
      });
    });

    group('roundToStep', () {
      test('redondea a múltiplo de 2.5', () {
        // 101.0 / 2.5 = 40.4 → round(40) = 40 → 40*2.5 = 100.0
        expect(CalculationUtils.roundToStep(101.0, 2.5), equals(100.0));
        // 101.3 / 2.5 = 40.52 → round(41) = 41 → 41*2.5 = 102.5
        expect(CalculationUtils.roundToStep(101.3, 2.5), equals(102.5));
        // 102.4 / 2.5 = 40.96 → round(41) = 41 → 41*2.5 = 102.5
        expect(CalculationUtils.roundToStep(102.4, 2.5), equals(102.5));
      });
    });
  });
}
