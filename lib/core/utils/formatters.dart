import 'package:flutter/services.dart';
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

/// A [TextInputFormatter] that keeps only digit characters (0-9) and inserts a
/// dot ('.') as a thousands separator in real time.
///
/// Pasting non-numeric text is supported by stripping everything that isn't a
/// digit first. Cursor placement is preserved by counting digits around the
/// caret rather than relying on raw character offsets, so the caret never
/// jumps to the end while typing and backspace always removes a digit, never a
/// separator dot.
class NumberInputFormatter extends TextInputFormatter {
  const NumberInputFormatter();

  /// Formats [digits] (which must contain only ASCII digits) with '.' every
  /// three digits counting from the right, e.g. "1000000" -> "1.000.000".
  static String _formatDigits(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    final n = digits.length;
    for (var i = 0; i < n; i++) {
      buffer.write(digits[i]);
      // Insert a separator after this digit when the remaining run of digits
      // to its right is a positive, non-zero modulo 3 (i.e. groups of three).
      final remaining = n - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  /// Counts how many ASCII digits appear in [text] before [offset].
  static int _digitsBefore(String text, int offset) {
    var count = 0;
    final end = offset.clamp(0, text.length);
    for (var i = 0; i < end; i++) {
      final c = text.codeUnitAt(i);
      if (c >= 0x30 && c <= 0x39) count++;
    }
    return count;
  }

  /// Maps a digit count back to the character offset inside [formatted].
  static int _offsetInFormatted(String formatted, int digitsBefore) {
    if (digitsBefore <= 0) return 0;
    var count = 0;
    for (var i = 0; i < formatted.length; i++) {
      final c = formatted.codeUnitAt(i);
      if (c >= 0x30 && c <= 0x39) {
        count++;
        if (count == digitsBefore) return i + 1;
      }
    }
    return formatted.length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only ASCII digits — this handles typing, paste and any stray
    // (e.g. alphabetic) characters that slipped into the proposed value.
    final newDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Nothing left to show — clear the field entirely.
    if (newDigits.isEmpty) {
      return TextEditingValue.empty;
    }

    final formatted = _formatDigits(newDigits);

    // Already in the desired form — return untouched to avoid cursor drift
    // (e.g. when the framework re-posts an already-formatted value).
    if (newValue.text == formatted) {
      return newValue;
    }

    final selection = newValue.selection;
    final digitsBeforeEnd =
        _digitsBefore(newValue.text, selection.extentOffset).clamp(0, newDigits.length);

    // Collapsed caret (the common case): map the digit position to the offset
    // inside the formatted string so the caret stays where the user expects.
    if (selection.isCollapsed) {
      final offset = _offsetInFormatted(formatted, digitsBeforeEnd);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: offset),
        composing: TextRange.empty,
      );
    }

    // A ranged selection (rare for numeric fields): map both bounds.
    final digitsBeforeStart =
        _digitsBefore(newValue.text, selection.baseOffset).clamp(0, newDigits.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection(
        baseOffset: _offsetInFormatted(formatted, digitsBeforeStart),
        extentOffset: _offsetInFormatted(formatted, digitsBeforeEnd),
        affinity: selection.affinity,
        isDirectional: selection.isDirectional,
      ),
      composing: TextRange.empty,
    );
  }
}
