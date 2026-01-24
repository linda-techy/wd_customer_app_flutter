import 'package:flutter/material.dart';

import '../constants.dart';

ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding * 1.5, vertical: defaultPadding),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    elevation: 2,
    shadowColor: primaryColor.withOpacity(0.3),
    shadowColor: primaryColor.withOpacity(0.3),
    shape: const StadiumBorder(),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),
);

OutlinedButtonThemeData outlinedButtonTheme(
    {Color borderColor = blackColor10}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding * 1.5, vertical: defaultPadding),
      minimumSize: const Size(double.infinity, 48),
      side: BorderSide(width: 1.5, color: borderColor),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

final textButtonThemeData = TextButtonThemeData(
  style: TextButton.styleFrom(foregroundColor: primaryColor),
);
