import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF00897B);

  static const Color statusReady = Color(0xFF388E3C);
  static const Color statusOccupied = Color(0xFF1976D2);
  static const Color statusDirty = Color(0xFFFFA000);
  static const Color statusOutOfService = Color(0xFFD32F2F);
  static const Color statusLocked = Color(0xFFEF5350);
  static const Color statusPending = Color(0xFFFB8C00);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          secondary: secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        navigationRailTheme: const NavigationRailThemeData(
          selectedIconTheme: IconThemeData(color: primary),
          selectedLabelTextStyle: TextStyle(color: primary, fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      );
}
