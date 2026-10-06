import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bảng màu chủ đề "Champagne Gold" — vàng champagne trên nền espresso và ngà.
/// Màu trạng thái phòng cố định, không trùng màu thương hiệu (xem canvas thiết kế).
class AppColors {
  // Thương hiệu
  static const Color gold = Color(0xFFC9A24D);
  static const Color goldDark = Color(0xFFB08A36);
  static const Color goldLight = Color(0xFFE6CB8B);
  static const Color goldText =
      Color(0xFF7A5A14); // chữ vàng trên nền sáng — đạt 4.5:1
  static const Color goldTint = Color(0xFFF6EFDD);
  static const Color espresso = Color(0xFF1F1B16);
  static const Color espressoDeep = Color(0xFF14110D);

  // Nền & chữ
  static const Color bg = Color(0xFFF8F6F1);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE7E1D5);
  static const Color borderStrong = Color(0xFFD6CFC2);
  static const Color divider = Color(0xFFEFEBE3);
  static const Color text = Color(0xFF1F1B16);
  static const Color muted = Color(0xFF6B6356);
  static const Color onDarkMuted = Color(0xFFBFB39C);
  static const Color onDark = Color(0xFFD9D0C1);

  // Trạng thái
  static const Color ready = Color(0xFF2E7D32);
  static const Color readyBg = Color(0xFFE7F3E8);
  static const Color occupied = Color(0xFF1E5FAE);
  static const Color occupiedBg = Color(0xFFE5EEF9);
  static const Color dirty = Color(0xFFB4471C);
  static const Color dirtyBg = Color(0xFFFCEBE2);
  static const Color cleaning = Color(0xFF6246B8);
  static const Color cleaningBg = Color(0xFFEEE9FA);
  static const Color inspect = Color(0xFF9C2F6B);
  static const Color inspectBg = Color(0xFFFAE8F1);
  static const Color oos = Color(0xFF57524A);
  static const Color oosBg = Color(0xFFEDEAE4);
  static const Color danger = Color(0xFFC0262D);
  static const Color dangerBg = Color(0xFFFDEBEC);
  static const Color neutral = Color(0xFF6B6356);
  static const Color neutralBg = Color(0xFFEFEBE3);
  static const Color dotMuted = Color(0xFFBDB5A7);
}

class AppTheme {
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  static TextTheme _textTheme(TextTheme base) =>
      GoogleFonts.beVietnamProTextTheme(base)
          .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.gold,
      onPrimary: AppColors.espresso,
      primaryContainer: AppColors.goldTint,
      onPrimaryContainer: AppColors.goldText,
      secondary: AppColors.espresso,
      onSecondary: AppColors.goldLight,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.danger,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.border,
    );
    final text = _textTheme(base.textTheme);

    OutlineInputBorder inputBorder(Color c, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: text,
      primaryTextTheme: text,
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
          color: AppColors.divider, space: 1, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        actionsIconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: inputBorder(AppColors.borderStrong),
        enabledBorder: inputBorder(AppColors.borderStrong),
        focusedBorder: inputBorder(AppColors.goldDark, 2),
        errorBorder: inputBorder(AppColors.danger),
        focusedErrorBorder: inputBorder(AppColors.danger, 2),
        labelStyle: const TextStyle(color: AppColors.muted),
        floatingLabelStyle: const TextStyle(
            color: AppColors.goldText, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: AppColors.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.espresso,
          disabledBackgroundColor: AppColors.neutralBg,
          disabledForegroundColor: const Color(0xFF948B7C),
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.espresso,
          disabledBackgroundColor: AppColors.neutralBg,
          disabledForegroundColor: const Color(0xFF948B7C),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldText,
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.espresso,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(
            color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(
            color: AppColors.goldLight,
            fontSize: 13,
            fontWeight: FontWeight.w600),
        checkmarkColor: AppColors.goldLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg)),
        titleTextStyle: text.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(radiusLg))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.espresso,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: AppColors.goldLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.goldTint,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected)
                  ? AppColors.goldText
                  : AppColors.muted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: s.contains(WidgetState.selected)
                  ? AppColors.goldText
                  : AppColors.muted,
            )),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd)),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.gold),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.goldText,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.gold,
      ),
    );
  }
}
