import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFontSize { small, normal, large }

class DisplaySettingsController extends ChangeNotifier {
  static const String _fontSizeKey = 'app_font_size';
  static const String _meetingTitleLabelKey = 'meeting_title_label';
  static const String _dateTimeLabelKey = 'date_time_label';

  static const String defaultMeetingTitleLabel = 'Meeting Title';
  static const String defaultDateTimeLabel = 'Select Date and Time';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  AppFontSize _fontSize = AppFontSize.normal;
  String _meetingTitleLabel = defaultMeetingTitleLabel;
  String _dateTimeLabel = defaultDateTimeLabel;
  bool _initialized = false;

  AppFontSize get fontSize => _fontSize;
  String get meetingTitleLabel => _meetingTitleLabel;
  String get dateTimeLabel => _dateTimeLabel;
  bool get initialized => _initialized;

  double get textScaleFactor {
    switch (_fontSize) {
      case AppFontSize.small:
        return 0.90;
      case AppFontSize.normal:
        return 1.00;
      case AppFontSize.large:
        return 1.15;
    }
  }

  String get fontSizeName {
    switch (_fontSize) {
      case AppFontSize.small:
        return 'Small';
      case AppFontSize.normal:
        return 'Default';
      case AppFontSize.large:
        return 'Large';
    }
  }

  Future<void> initialize() async {
    final savedFontSize = await _preferences.getString(_fontSizeKey);
    final savedMeetingLabel = await _preferences.getString(
      _meetingTitleLabelKey,
    );
    final savedDateTimeLabel = await _preferences.getString(_dateTimeLabelKey);

    switch (savedFontSize) {
      case 'small':
        _fontSize = AppFontSize.small;
        break;
      case 'large':
        _fontSize = AppFontSize.large;
        break;
      case 'normal':
      default:
        _fontSize = AppFontSize.normal;
        break;
    }

    _meetingTitleLabel = _cleanLabel(
      savedMeetingLabel,
      defaultMeetingTitleLabel,
    );
    _dateTimeLabel = _cleanLabel(savedDateTimeLabel, defaultDateTimeLabel);

    _initialized = true;
    notifyListeners();
  }

  Future<void> setFontSize(AppFontSize size) async {
    _fontSize = size;
    notifyListeners();

    await _preferences.setString(_fontSizeKey, size.name);
  }

  Future<void> saveBookingLabels({
    required String meetingTitleLabel,
    required String dateTimeLabel,
  }) async {
    _meetingTitleLabel = _cleanLabel(
      meetingTitleLabel,
      defaultMeetingTitleLabel,
    );

    _dateTimeLabel = _cleanLabel(dateTimeLabel, defaultDateTimeLabel);

    notifyListeners();

    await _preferences.setString(_meetingTitleLabelKey, _meetingTitleLabel);

    await _preferences.setString(_dateTimeLabelKey, _dateTimeLabel);
  }

  Future<void> resetBookingLabels() async {
    _meetingTitleLabel = defaultMeetingTitleLabel;
    _dateTimeLabel = defaultDateTimeLabel;

    notifyListeners();

    await _preferences.setString(_meetingTitleLabelKey, _meetingTitleLabel);

    await _preferences.setString(_dateTimeLabelKey, _dateTimeLabel);
  }

  String _cleanLabel(String? value, String fallback) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
  }
}
