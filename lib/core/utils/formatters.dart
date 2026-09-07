import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Lazily created so the static initializer can't run before the
  /// `id_ID` locale data is loaded (see `main.dart`). `NumberFormat.currency`
  /// only needs number symbols, which are bundled, but keeping this lazy avoids
  /// any eager locale access during an isolate's first import.
  static NumberFormat? _idrCache;
  static NumberFormat get _idr => _idrCache ??=
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static String idr(num v) => _idr.format(v);

  static String compactIdr(num v) {
    if (v >= 1e9) return 'Rp ${(v / 1e9).toStringAsFixed(v % 1e9 == 0 ? 0 : 1)} M';
    if (v >= 1e6) return 'Rp ${(v / 1e6).toStringAsFixed(1)} jt';
    return idr(v);
  }

  /// Formats using `id_ID` date symbols when available and falls back to the
  /// default locale if `initializeDateFormatting('id_ID')` has not yet run
  /// (e.g. an offline/mock environment). Behaviour is identical to before once
  /// the locale is initialized in `main()`.
  static String date(DateTime d) => _format(d, false);

  static String dateTime(DateTime d) => _format(d, true);

  static String _format(DateTime d, bool withTime) {
    try {
      return DateFormat(
        withTime ? 'dd MMM yyyy • HH:mm' : 'dd MMM yyyy',
        'id_ID',
      ).format(d);
    } catch (_) {
      // Locale symbols not loaded yet — use the default locale instead of
      // crashing. Indonesian names come back once `main()` finishes init.
      return DateFormat(withTime ? 'dd MMM yyyy • HH:mm' : 'dd MMM yyyy').format(d);
    }
  }
}
