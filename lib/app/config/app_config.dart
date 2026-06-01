import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  /// URL de base de l'API. Lu depuis le .env, fallback sur émulateur Android.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1';

  /// URL d'authentification OAuth2 Google côté backend.
  static String googleOAuthUrl(String redirectUri) =>
      '$apiBaseUrl/oauth2/authorize/google?redirect_uri=$redirectUri';

  /// Scheme custom pour le retour OAuth2 (deep link).
  static String get oauthRedirectScheme =>
      dotenv.env['OAUTH_REDIRECT_SCHEME'] ?? 'gesper';

  static String get oauthRedirectUri =>
      dotenv.env['OAUTH_REDIRECT_URI'] ?? 'gesper://oauth2/redirect';

  /// Devise par défaut.
  static const String defaultCurrencySymbol = '€';
  static const String defaultLocale = 'fr_FR';

  /// Timeouts réseau.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}