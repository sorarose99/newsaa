import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF388E3C);
  static const Color secondaryGold = Color(0xFFD4A574);
  static const Color accentColor = Color(0xFF4CAF50);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGold,
      surface: Colors.white,
      error: Colors.red,
    ),
    textTheme: GoogleFonts.cairoTextTheme().copyWith(
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryGreen,
      ),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, color: Colors.black87),
      displayLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        height: 2.0,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      trackVisibility: WidgetStateProperty.all(false),
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(10),
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.hovered)) {
          return primaryGreen.withValues(alpha: 0.8);
        }
        return primaryGreen.withValues(alpha: 0.5);
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: secondaryGold,
      surface: Color(0xFF1E1E1E),
      error: Colors.red,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: secondaryGold,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: secondaryGold,
      ),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, color: Colors.white70),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, color: Colors.white70),
      displayLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
        height: 2.0,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: secondaryGold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: secondaryGold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      trackVisibility: WidgetStateProperty.all(false),
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(10),
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.hovered)) {
          return secondaryGold.withValues(alpha: 0.8);
        }
        return secondaryGold.withValues(alpha: 0.5);
      }),
    ),
  );

  static ThemeData getTheme(String style, {bool isDark = false}) {
    if (isDark || style == 'dark') return darkTheme;

    Color primary;
    Color scaffoldBackground;
    Color canvas;
    Color onPrimary = Colors.white;
    Color secondary;
    Color primaryContainer;
    Color onPrimaryContainer = Colors.black87;

    switch (style) {
      case 'brown':
        primary = const Color(0xff583623);
        scaffoldBackground = const Color(0xffFDF7F4);
        canvas = const Color(0xffFDF7F4);
        secondary = const Color(0xff854621);
        primaryContainer = const Color(0xffFDF7F4);
        break;
      case 'old':
        primary = const Color(0xff232c13);
        scaffoldBackground = const Color(0xfff3efdf);
        canvas = const Color(0xfff3efdf);
        secondary = const Color(0xff91a57d);
        primaryContainer = const Color(0xfff3efdf);
        break;
      case 'blue':
        primary = const Color(0xff404C6E);
        scaffoldBackground = const Color(0xfffaf7f3);
        canvas = const Color(0xffFFFFFF);
        secondary = const Color(0xffCDAD80);
        primaryContainer = const Color(0xffFFFFFF);
        break;
      case 'green':
      default:
        primary = const Color(0xFF388E3C);
        scaffoldBackground = Colors.white;
        canvas = const Color(0xFFF1F8E9);
        secondary = const Color(0xFF43A047);
        primaryContainer = const Color(0xFFE8F5E9);
        break;
    }

    return lightTheme.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: canvas,
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: canvas,
        onSurface: Colors.black87,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
      ),
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      textTheme: lightTheme.textTheme
          .apply(bodyColor: Colors.black87, displayColor: Colors.black87)
          .copyWith(
            headlineLarge: lightTheme.textTheme.headlineLarge?.copyWith(
              color: primary,
            ),
            headlineMedium: lightTheme.textTheme.headlineMedium?.copyWith(
              color: primary,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: lightTheme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.all(primary),
          foregroundColor: WidgetStateProperty.all(onPrimary),
        ),
      ),
      cardTheme: lightTheme.cardTheme.copyWith(color: Colors.white),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: primary,
        indicatorColor: primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return IconThemeData(color: onPrimary.withValues(alpha: 0.8));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return GoogleFonts.cairo(
            color: onPrimary.withValues(alpha: 0.8),
            fontSize: 12,
          );
        }),
      ),
      scrollbarTheme: lightTheme.scrollbarTheme.copyWith(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered)) {
            return primary.withValues(alpha: 0.8);
          }
          return primary.withValues(alpha: 0.5);
        }),
      ),
    );
  }
}
