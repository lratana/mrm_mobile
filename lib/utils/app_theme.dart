import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static const AppPalette _lightPalette = AppPalette(
    background: Color(0xFFF6F8FB),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF3F6FA),
    surfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    text: Color(0xFF111827),
    textMuted: Color(0xFF6B7280),
    primarySoft: Color(0xFFE9F2FF),
    shadow: Color(0x12000000),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFDC2626),
  );

  static const AppPalette _darkPalette = AppPalette(
    background: Color(0xFF0B1220),
    surface: Color(0xFF111827),
    surfaceSoft: Color(0xFF182235),
    surfaceRaised: Color(0xFF1D293D),
    border: Color(0xFF293548),
    text: Color(0xFFF9FAFB),
    textMuted: Color(0xFF9CA3AF),
    primarySoft: Color(0xFF102A4C),
    shadow: Color(0x60000000),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  static ThemeData get light {
    return _buildTheme(brightness: Brightness.light, palette: _lightPalette);
  }

  static ThemeData get dark {
    return _buildTheme(brightness: Brightness.dark, palette: _darkPalette);
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppPalette palette,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppConstants.primary,
      brightness: brightness,
      primary: AppConstants.primary,
      surface: palette.surface,
      error: palette.danger,
    );

    final textTheme = TextTheme(
      displaySmall: TextStyle(
        color: palette.text,
        fontSize: 30,
        fontWeight: FontWeight.w900,
        height: 1.15,
      ),
      headlineSmall: TextStyle(
        color: palette.text,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        color: palette.text,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        color: palette.text,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(
        color: palette.text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: palette.text,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: palette.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        color: palette.text,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[
        // Replaced below with palette through copyWith.
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primarySoft,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        prefixIconColor: AppConstants.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppConstants.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primary,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceRaised,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        textStyle: textTheme.bodyMedium,
      ),
    ).copyWith(extensions: <ThemeExtension<dynamic>>[palette]);
  }
}
