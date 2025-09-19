import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/utils/responsive.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFF29620);
  static const Color darkOrange = Color(0xFFE8851C);
  static const Color lightOrange = Color(0xFFFFF4E6);
  
  // Neutral Colors
  static const Color darkGray = Color(0xFF2D3748);
  static const Color mediumGray = Color(0xFF4A5568);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color borderGray = Color(0xFFE2E8F0);
  
  // Status Colors
  static const Color successGreen = Color(0xFF38A169);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color warningYellow = Color(0xFFD69E2E);
  
  /// Get responsive text theme based on screen size
  static TextTheme getResponsiveTextTheme(BuildContext context) {
    return GoogleFonts.interTextTheme(
      ThemeData.light().textTheme.copyWith(
        headlineLarge: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 28,
            tablet: 32,
            desktop: 36,
            largeDesktop: 40,
          ),
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
        headlineMedium: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
            largeDesktop: 36,
          ),
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
        headlineSmall: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
            largeDesktop: 32,
          ),
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        titleLarge: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
            largeDesktop: 24,
          ),
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        titleMedium: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
            largeDesktop: 22,
          ),
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        bodyLarge: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
            largeDesktop: 22,
          ),
          fontWeight: FontWeight.normal,
          color: mediumGray,
        ),
        bodyMedium: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
            largeDesktop: 20,
          ),
          fontWeight: FontWeight.normal,
          color: mediumGray,
        ),
        bodySmall: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
            largeDesktop: 18,
          ),
          fontWeight: FontWeight.normal,
          color: mediumGray,
        ),
        labelLarge: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
            largeDesktop: 22,
          ),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
            largeDesktop: 20,
          ),
          fontWeight: FontWeight.w500,
          color: mediumGray,
        ),
        labelSmall: TextStyle(
          fontSize: Responsive.fontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
            largeDesktop: 18,
          ),
          fontWeight: FontWeight.w500,
          color: mediumGray,
        ),
      ),
    );
  }

  /// Get responsive spacing values
  static ResponsiveSpacing spacing(BuildContext context) {
    return ResponsiveSpacing(
      xs: Responsive.spacing(context, mobile: 4, tablet: 6, desktop: 8),
      sm: Responsive.spacing(context, mobile: 8, tablet: 12, desktop: 16),
      md: Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24),
      lg: Responsive.spacing(context, mobile: 24, tablet: 32, desktop: 40),
      xl: Responsive.spacing(context, mobile: 32, tablet: 40, desktop: 48),
      xxl: Responsive.spacing(context, mobile: 48, tablet: 56, desktop: 64),
    );
  }

  /// Get responsive padding values
  static ResponsivePadding padding(BuildContext context) {
    final s = spacing(context);
    return ResponsivePadding(
      screen: EdgeInsets.all(s.md),
      card: EdgeInsets.all(s.md),
      section: EdgeInsets.symmetric(vertical: s.lg, horizontal: s.md),
      element: EdgeInsets.all(s.sm),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.light,
        primary: primaryOrange,
        secondary: darkOrange,
        surface: Colors.white,
        background: lightGray,
        error: errorRed,
      ),
      // Base text theme - will be overridden by responsive theme in widgets
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          headlineLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
          headlineMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
          headlineSmall: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: darkGray,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: mediumGray,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: mediumGray,
          ),
          labelLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: mediumGray,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: mediumGray,
          fontSize: 14,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
      ),
    );
  }
}

/// Responsive spacing class to hold different spacing values
class ResponsiveSpacing {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  const ResponsiveSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });
}

/// Responsive padding class to hold different padding values
class ResponsivePadding {
  final EdgeInsets screen;
  final EdgeInsets card;
  final EdgeInsets section;
  final EdgeInsets element;

  const ResponsivePadding({
    required this.screen,
    required this.card,
    required this.section,
    required this.element,
  });
}
