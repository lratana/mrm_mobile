import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();
  // Change this to your Laravel API base URL.
  // Android emulator local Laravel: http://10.0.2.2:8000/api
  // iOS simulator local Laravel: http://127.0.0.1:8000/api
  static const String baseUrl = 'https://starlink98.cloud';

  // Used to convert Laravel public disk image paths such as rooms/images/a.jpg
  // into http://.../storage/rooms/images/a.jpg
  static const String storageBaseUrl = 'https://starlink98.cloud/storage';

  // Put a valid Bearer token here, or replace ApiService token logic with login/secure storage.
  static const String authToken = '';

  // Auth endpoints. Change these if your Laravel auth routes use a different prefix.
  static const String loginPath = 'api/signin';
  static const String registerPath = 'api/register';
  static const String forgotPasswordPath = 'api/forgot-password';
  static const String logoutPath = 'api/logout';

  static const String loginHeroAsset = 'assets/images/login_hero.jpg';
  static const String resetHeroAsset = 'assets/images/reset_hero.jpg';

  static const Duration requestTimeout = Duration(seconds: 25);

  static const Color primary = Color(0xFF00666A);
  static const Color primaryDark = Color(0xFF004F52);
  static const Color mint = Color(0xFFB9F0E7);
  static const Color chipBg = Color(0xFFE8F7F4);
  static const Color softBlue = Color(0xFFE9F0FF);
  static const Color bg = Color(0xFFF8F7FC);
  static const Color text = Color(0xFF101828);
  static const Color muted = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);

  static const double pagePadding = 18;
  static const double radius = 18;

  // static const double pagePadding = 20;

  // Brand colors: these can remain consistent in light/dark mode.
  // static const Color primary = Color(0xFF0969DA);
  // static const Color primaryDark = Color(0xFF074EA8);
  // static const Color mint = Color(0xFFDDF7EC);

  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
}
