import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:gesper_app/app/config/app_config.dart';
import 'package:gesper_app/app/routes/app_routes.dart';
import 'package:gesper_app/core/utils/app_toast.dart';
import 'package:gesper_app/data/services/auth_service.dart';
import 'package:get/get.dart';

/// Écoute les deep links `gesper://oauth2/redirect?token=...&refreshToken=...`
/// renvoyés par le backend Spring après login Google.
class OAuthDeepLinkHandler {
  static final OAuthDeepLinkHandler _instance = OAuthDeepLinkHandler._();
  factory OAuthDeepLinkHandler() => _instance;
  OAuthDeepLinkHandler._();

  StreamSubscription<Uri>? _sub;
  late final AppLinks _appLinks;

  Future<void> init() async {
    _appLinks = AppLinks();
    // App ouverte par le lien (cold start)
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handle(initial);
    } catch (_) {}
    // App déjà ouverte
    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
  }

  void _handle(Uri uri) {
    if (uri.scheme != AppConfig.oauthRedirectScheme) return;

    final token = uri.queryParameters['token'];
    final refresh = uri.queryParameters['refreshToken'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      AppToast.error(Uri.decodeComponent(error));
      return;
    }

    if (token == null || refresh == null) return;

    _loginWithTokens(token, refresh);
  }

  Future<void> _loginWithTokens(String access, String refresh) async {
    try {
      await AuthService.to.loginWithTokens(accessToken: access, refreshToken: refresh);
      AppToast.success('Connexion réussie !');
      // Attendre un instant que GetX ait pris la main
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.home);
      });
    } catch (e) {
      AppToast.error('Erreur lors du login Google');
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
