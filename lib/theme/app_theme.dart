import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const String fontFamily = 'Futura';
  // Common base TextStyles with sizes and weights — only color differs in themes
  static const TextStyle _titleMediumBase = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  static const TextStyle _bodyLargeBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
  );
  static const TextStyle _bodyMediumBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
  );
  static const TextStyle _labelLargeBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
  );
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.text,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    textTheme: TextTheme(
      bodyMedium: _bodyMediumBase.copyWith(color: AppColors.text),
      bodyLarge: _bodyLargeBase.copyWith(color: AppColors.text),
      labelLarge: _labelLargeBase.copyWith(color: AppColors.text),
      titleMedium: _titleMediumBase.copyWith(color: AppColors.text),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      onPrimary: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cta,
        foregroundColor: AppColors.text,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(color: AppColors.primary, fontFamily: fontFamily),
      selectedColor: AppColors.cta,
      disabledColor: Colors.grey,
      secondarySelectedColor: AppColors.primary,
      brightness: Brightness.light,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontFamily: fontFamily),
      unselectedLabelStyle: const TextStyle(fontFamily: fontFamily),
    ),
    cardColor: Colors.white,
    dividerColor: AppColors.primary.withOpacity(0.2),
  );
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.text, // #3B3B3B charcoal
    primaryColor: AppColors.primary,
    fontFamily: fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.ctaLight,
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    textTheme: TextTheme(
      bodyMedium: _bodyMediumBase.copyWith(color: AppColors.ctaLight),
      bodyLarge: _bodyLargeBase.copyWith(color: AppColors.ctaLight),
      labelLarge: _labelLargeBase.copyWith(color: AppColors.primary),
      titleMedium: _titleMediumBase.copyWith(color: AppColors.cta),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cta,
        foregroundColor: AppColors.text,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(color: AppColors.primary, fontFamily: fontFamily),
      selectedColor: AppColors.cta,
      disabledColor: Colors.grey,
      secondarySelectedColor: AppColors.primary,
      brightness: Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.text,
      selectedItemColor: AppColors.ctaLight,
      unselectedItemColor: AppColors.ctaLight.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontFamily: fontFamily),
      unselectedLabelStyle: const TextStyle(fontFamily: fontFamily),
    ),
    cardColor: AppColors.text.withOpacity(0.95),
    dividerColor: AppColors.primary.withOpacity(0.2),
  );
}
