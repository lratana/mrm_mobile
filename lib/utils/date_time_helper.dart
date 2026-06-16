class DateTimeHelper {
  /// Convert LOCAL (Phnom Penh) → UTC for API
  static DateTime toUtc(DateTime local) {
    return local.toUtc();
  }

  /// Convert UTC → LOCAL (Phnom Penh) for UI display
  static DateTime toLocal(DateTime utc) {
    return utc.toLocal();
  }
}
