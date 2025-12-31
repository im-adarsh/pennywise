import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF388E3C); // Forest green
  static const Color backgroundColor = Color(0xFFE8F5E9); // Light green
  static const Color accentColor = Color(0xFF26A69A); // Teal
  static const Color textColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color cardColor = Colors.white;

  // Material 3 Color Schemes
  static ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
  }

  static ColorScheme get darkColorScheme {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.ptSansTextTheme(
        TextTheme(
          displayLarge: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
          displayMedium: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
          displaySmall: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          headlineLarge: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
          headlineMedium: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
          headlineSmall: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
          titleLarge: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
          titleMedium: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
          titleSmall: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
          bodyLarge: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: textColor),
          bodyMedium: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
          bodySmall: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: textSecondaryColor),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.ptSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.ptSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.ptSansTextTheme(
        TextTheme(
          displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface),
          displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface),
          displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface),
          headlineLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface),
          headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface),
          headlineSmall: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface),
          titleLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface),
          titleMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface),
          titleSmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface),
          bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: colorScheme.onSurface),
          bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: colorScheme.onSurface),
          bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: colorScheme.onSurfaceVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.ptSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surfaceContainerHighest,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.ptSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
