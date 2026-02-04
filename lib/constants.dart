import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Construction Project Demo Images (placeholders)
const constructionDemoImg1 =
    "https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800"; // Building construction
const constructionDemoImg2 =
    "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800"; // Construction site
const constructionDemoImg3 =
    "https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800"; // Modern building
const constructionDemoImg4 =
    "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800"; // Office building
const constructionDemoImg5 =
    "https://images.unsplash.com/photo-1590948347862-c1c4e5e0e3de?w=800"; // Industrial
const constructionDemoImg6 =
    "https://images.unsplash.com/photo-1513584684374-8bab748fbf90?w=800"; // Residential

// Brand Font
const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

// Construction Company Color Scheme - Professional & Trustworthy
const Color primaryColor =
    Color(0xFFD84940); // Red from logo - represents energy and completion

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFFD84940, <int, Color>{
  50: Color(0xFFFDF2F2),
  100: Color(0xFFFBE6E5),
  200: Color(0xFFF7D0CE),
  300: Color(0xFFF2BAB7),
  400: Color(0xFFEEA4A0),
  500: Color(0xFFD84940), // Primary
  600: Color(0xFFC2423A),
  700: Color(0xFFAC3B33),
  800: Color(0xFF96342D),
  900: Color(0xFF802D26),
});

// Logo-inspired Color Scheme
const Color logoBackground = Color(0xFF16161E); // Deep black from logo
const Color logoGreyDark = Color(0xFF363636); // Dark grey dots from logo
const Color logoGreyLight = Color(0xFF666666); // Light grey dots from logo
const Color logoRed = Color(0xFFD84940); // Red accent from logo
const Color logoPink = Color(0xFFFF69B4); // Pink connecting lines from logo

// Secondary Colors for Construction Theme
const Color secondaryColor = Color(0xFF363636); // Dark grey from logo
const Color accentColor = Color(0xFF666666); // Light grey from logo
const Color constructionYellow = Color(0xFFE9C46A); // Safety Yellow
const Color constructionRed = Color(0xFFE76F51); // Safety Red

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color surfaceColor = Color(0xFFFAFAFA); // Premium reduced-glare white
const Color surfaceColorDark = Color(0xFF20202A); // Premium dark surface


const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF2C5F2D);
const Color successColor = Color(0xFF00C853); // Emerald Green
const Color warningColor = Color(0xFFFFAB00); // Safety Orange
const Color errorColor = Color(0xFFD32F2F); // Material Red 700

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);
const Duration kDefaultDuration = Duration(milliseconds: 300);
const Duration kFastDuration = Duration(milliseconds: 200);
const Duration kSlowDuration = Duration(milliseconds: 600);
const Curve kButtonScaleCurve = Curves.easeOut;
const Curve kStandardCurve = Curves.easeInOut;

// TEMPORARY: Simplified password validator for testing
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  // MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  // PatternValidator(r'(?=.*?[#?!@$%^&*-])',
  //     errorText: 'passwords must have at least one special character')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";

/// Company contact email - use for all mailto, contact, and support links.
const String companyEmail = 'info@walldotbuilders.com';
