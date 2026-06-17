import 'package:intl/intl.dart';

class DateTimeHelper {
  /// LOCAL → UTC
  static DateTime toUtc(DateTime local) => local.toUtc();

  /// UTC → LOCAL
  static DateTime toLocal(DateTime utc) => utc.toLocal();

  /// LOCAL/UTC → API UTC DB FORMAT
  /// Example: 2026-06-17 08:42:00
  static String toApiUtcString(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toUtc());
  }

  static DateTime? asDate(dynamic value) {
    if (value == null) return null;

    final raw = value.toString().trim();

    if (raw.isEmpty) return null;

    try {
      // Check if backend already sends timezone:
      // 2026-06-17T09:01:00Z
      // 2026-06-17T09:01:00+00:00
      final hasTimezone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);

      final normalized = raw.replaceFirst(' ', 'T');

      if (hasTimezone) {
        return DateTime.parse(normalized).toUtc();
      }

      // ✅ Backend sends UTC but without Z:
      // 2026-06-17 09:01:00
      // Treat it as UTC, not local.
      return DateTime.parse('${normalized}Z').toUtc();
    } catch (_) {
      return null;
    }
  }

  /// SAFE compare
  static bool isSameMoment(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;

    return a.toUtc().millisecondsSinceEpoch == b.toUtc().millisecondsSinceEpoch;
  }

  /// OVERLAP CHECK
  static bool isOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    final aStart = startA.toUtc();
    final aEnd = endA.toUtc();
    final bStart = startB.toUtc();
    final bEnd = endB.toUtc();

    return aStart.isBefore(bEnd) && aEnd.isAfter(bStart);
  }
}
