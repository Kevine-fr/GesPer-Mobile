import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Contrôleur global du thème : clair / sombre / système. Persistance via GetStorage.
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  static const _key = 'theme_mode';
  final _box = GetStorage();

  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    final raw = _box.read<String>(_key);
    mode.value = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  bool get isDark {
    if (mode.value == ThemeMode.system) {
      return Get.mediaQuery.platformBrightness == Brightness.dark;
    }
    return mode.value == ThemeMode.dark;
  }

  Future<void> toggle() async {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    await _persist();
    Get.changeThemeMode(mode.value);
  }

  Future<void> setMode(ThemeMode m) async {
    mode.value = m;
    await _persist();
    Get.changeThemeMode(m);
  }

  Future<void> _persist() async {
    final raw = switch (mode.value) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _box.write(_key, raw);
  }
}
