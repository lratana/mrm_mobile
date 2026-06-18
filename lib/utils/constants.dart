import 'package:flutter/material.dart';

class AppConstants {
  // AppConstants._();

  static const bool isProduction = false;

  static const String baseUrl = isProduction
      ? 'https://starlink98.cloud'
      : 'http://10.0.2.2:8000';

  static const String storageBaseUrl = isProduction
      ? 'https://starlink98.cloud/storage'
      : 'http://10.0.2.2:8000/storage';

  // Change this to your Laravel API base URL.
  // Android emulator local Laravel: http://10.0.2.2:8000/api
  // iOS simulator local Laravel: http://127.0.0.1:8000/api
  // static const String baseUrl = 'https://starlink98.cloud';
  // static const String baseUrl = 'http://10.0.2.2:8000';

  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  // static const String storageBaseUrl = 'http://10.0.2.2:8000/storage';

  // Used to convert Laravel public disk image paths such as rooms/images/a.jpg
  // into http://.../storage/rooms/images/a.jpg
  // static const String storageBaseUrl = 'https://starlink98.cloud/storage';

  // Put a valid Bearer token here, or replace ApiService token logic with login/secure storage.
  static const String authToken = '';

  // Auth endpoints. Change these if your Laravel auth routes use a different prefix.

  // =========================
  // Auth Public Routes
  // =========================
  static const String loginPath = 'api/signin';
  static const String registerPath = 'api/signup';

  static const String forgotPasswordPath = 'api/password/forgot';
  static const String resetPasswordPath = 'api/password/reset';

  static const String resendEmailVerificationPath = 'api/email/verify/resend';

  // =========================
  // Google OAuth Routes
  // =========================
  static const String googleAuthPath = 'api/auth/google';
  static const String googleCallbackPath = 'api/auth/google/callback';

  // =========================
  // Protected Auth Routes
  // Need Bearer Token
  // =========================
  static const String logoutPath = 'api/signout';
  static const String refreshTokenPath = 'api/token/refresh';
  static const String verifyAccountPath = 'api/verify/account';
  static const String changePasswordPath = 'api/password/change';
  static const String createPasswordPath = 'api/password/create';
  static const String updateProfilePath = 'api/update/photo';

  static const String loginHeroAsset = 'assets/images/login_hero.jpg';
  static const String appLogoAsset = 'assets/images/logos.png';
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
  static const Color warning = Color.fromARGB(0, 255, 161, 47);

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
