import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color surfaceRaised;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color primarySoft;
  final Color shadow;
  final Color success;
  final Color warning;
  final Color danger;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.surfaceRaised,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.primarySoft,
    required this.shadow,
    required this.success,
    required this.warning,
    required this.danger,
  });

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? surfaceRaised,
    Color? border,
    Color? text,
    Color? textMuted,
    Color? primarySoft,
    Color? shadow,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      primarySoft: primarySoft ?? this.primarySoft,
      shadow: shadow ?? this.shadow,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;

    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  ColorScheme get appScheme => Theme.of(this).colorScheme;

  TextTheme get appText => Theme.of(this).textTheme;

  AppPalette get appColors {
    return Theme.of(this).extension<AppPalette>()!;
  }

  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
