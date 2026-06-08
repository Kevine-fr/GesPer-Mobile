import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/bindings/initial_binding.dart';
import 'app/config/app_config.dart';
import 'app/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/values/app_strings.dart';
import 'data/services/oauth_deep_link_handler.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[MAIN] 1. WidgetsFlutterBinding OK');

    FlutterError.onError = (details) {
      debugPrint('[FLUTTER ERROR] ${details.exception}');
      debugPrint('[FLUTTER STACK] ${details.stack}');
    };

    // dotenv — on essaie mais on continue si ça plante
    try {
      await dotenv.load(fileName: 'assets/config/env');
      debugPrint('[MAIN] 2. dotenv OK, API_BASE_URL=${dotenv.env['API_BASE_URL']}');
    } catch (e, st) {
      debugPrint('[MAIN] 2. dotenv FAILED: $e');
      debugPrint('[STACK] $st');
    }

    try {
      await GetStorage.init();
      debugPrint('[MAIN] 3. GetStorage OK');
    } catch (e) {
      debugPrint('[MAIN] 3. GetStorage FAILED: $e');
    }

    try {
      await initializeDateFormatting(AppConfig.defaultLocale);
      debugPrint('[MAIN] 4. DateFormatting OK');
    } catch (e) {
      debugPrint('[MAIN] 4. DateFormatting FAILED: $e');
    }

    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      debugPrint('[MAIN] 5. Orientations OK');
    } catch (e) {
      debugPrint('[MAIN] 5. Orientations FAILED: $e');
    }

    try {
      InitialBinding().dependencies();
      debugPrint('[MAIN] 6. InitialBinding OK');
    } catch (e, st) {
      debugPrint('[MAIN] 6. InitialBinding FAILED: $e');
      debugPrint('[STACK] $st');
    }

    try {
      await OAuthDeepLinkHandler().init();
      debugPrint('[MAIN] 7. OAuth handler OK');
    } catch (e) {
      debugPrint('[MAIN] 7. OAuth handler FAILED: $e');
    }

    debugPrint('[MAIN] 8. Calling runApp...');
    runApp(const GesperApp());
    debugPrint('[MAIN] 9. runApp returned');
  }, (error, stack) {
    debugPrint('[ZONE FATAL] $error');
    debugPrint('[ZONE STACK] $stack');
  });
}

class GesperApp extends StatelessWidget {
  const GesperApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[APP] GesperApp.build');
    return Obx(() {
      return GetMaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeController.to.mode.value,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
        locale: const Locale('fr', 'FR'),
        fallbackLocale: const Locale('en', 'US'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
      );
    });
  }
}