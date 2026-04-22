import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _isoDate    = DateFormat('yyyy-MM-dd');
  static final _displayFull = DateFormat("EEEE, d 'de' MMMM", 'es_ES');
  static final _displayMed  = DateFormat('d MMM yyyy', 'es_ES');
  static final _displayShort = DateFormat('d MMM', 'es_ES');
  static final _displayTime  = DateFormat('HH:mm');

  static String toIso(DateTime d)    => _isoDate.format(d);
  static DateTime fromIso(String s)  => _isoDate.parse(s);

  static String formatFull(DateTime d)  => _displayFull.format(d);
  static String formatMed(DateTime d)   => _displayMed.format(d);
  static String formatShort(DateTime d) => _displayShort.format(d);
  static String formatTime(DateTime d)  => _displayTime.format(d);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Lunes de la semana que contiene [date].
  static DateTime startOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  static List<DateTime> daysOfWeek(DateTime date) {
    final start = startOfWeek(date);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  static int daysBetween(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  /// "1h 23min", "45min 10s", "8s"
  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}min';
    if (m > 0) return '${m}min ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  /// "MM:SS" o "HH:MM:SS" para cronómetro.
  static String formatChrono(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$mm:$ss';
    return '$mm:$ss';
  }

  /// Bitmask del día de hoy (Lun=1 … Dom=64).
  static int todayBitmask() => 1 << (DateTime.now().weekday - 1);

  static String weekdayName(int weekday) {
    const n = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];
    return n[(weekday - 1) % 7];
  }

  static String weekdayShort(int weekday) {
    const n = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
    return n[(weekday - 1) % 7];
  }

  static List<String> weekdaysFromBitmask(int bitmask) {
    final result = <String>[];
    for (var i = 0; i < 7; i++) {
      if (bitmask & (1 << i) != 0) result.add(weekdayName(i + 1));
    }
    return result;
  }
}
