import 'package:flutter/material.dart';
import 'button_theme.dart';
import 'input_decoration_theme.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: surfaceColor,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: blackColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: blackColor,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: blackColor,
          letterSpacing: -0.25,
        ),
        headlineLarge: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: blackColor,
          letterSpacing: -0.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: blackColor,
          letterSpacing: -0.25,
        ),
        headlineSmall: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: blackColor,
          letterSpacing: -0.25,
        ),
        titleLarge: TextStyle(
          fontFamily: grandisExtendedFont, // Use Grandis for major titles too
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: blackColor,
          letterSpacing: -0.25,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: blackColor,
          letterSpacing: -0.25,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: blackColor,
          letterSpacing: -0.25,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: blackColor,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: blackColor60,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: blackColor60,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: blackColor,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: blackColor,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: blackColor60,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
      cardTheme: CardTheme(
        elevation: 0, // Flat premium look by default, handled by wrappers
        color: whiteColor,
        shadowColor: blackColor.withOpacity(0.05),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: blackColor.withOpacity(0.05), width: 1),
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF16161E),
      iconTheme: const IconThemeData(color: Colors.white),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Color(0xFF20202A),
        error: Color(0xFFD32F2F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        headlineLarge: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        headlineSmall: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        titleLarge: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFB0B0B8),
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFFB0B0B8),
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFFB0B0B8),
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: darkInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: Colors.white38),
      ),
      appBarTheme: appBarDarkTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableDarkThemeData,
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF20202A),
        shadowColor: Colors.black.withOpacity(0.3),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1C25),
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF8A8A95),
      ),
      dividerColor: Colors.white12,
      dialogTheme: const DialogTheme(
        backgroundColor: Color(0xFF20202A),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: Color(0xFFB0B0B8), fontSize: 14),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF2C2C38),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primaryColor : const Color(0xFF8A8A95),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor.withOpacity(0.4)
              : const Color(0xFF3A3A45),
        ),
      ),
    );
  }
}
