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

  // Dark theme is inclided in the Full template
}
