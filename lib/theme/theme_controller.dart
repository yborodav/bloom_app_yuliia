import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.light);

  static void toggleTheme() {
    themeModeNotifier.value =
        themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}