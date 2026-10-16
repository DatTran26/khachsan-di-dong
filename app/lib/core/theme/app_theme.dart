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
  static const Color onDarkSoft = Color(0xFFCFC5B3);
  static const Color onDarkFaint = Color(0xFFA89C87); // 6.3:1 trên espresso
  static const Color onDarkOverlay = Color(0x1FFFFFFF);
  static const Color goldHairline =
      Color(0x40C9A24D); // đường kẻ vàng trên nền tối
  static const Color goldSelected =
      Color(0x29C9A24D); // nền mục đang chọn ở thanh bên
  static const Color surfaceMuted = Color(0xFFFAF8F3); // đầu bảng
  static const Color surfaceSunken =
      Color(0xFFF0ECE3); // khung chứa nhóm, thanh tiến độ
  static const Color track = Color(0xFFECE7DC); // nền nhóm nút chọn một
  static const Color iconMuted =
      Color(0xFF948B7C); // chỉ dùng cho icon/chữ bị vô hiệu

  // Trạng thái
  static const Color ready =
      Color(0xFF2D7B31); // 4.6:1 trên readyBg (chữ chip nhỏ cần ≥4.5:1)
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
  static const Color dangerSurface = Color(0xFFFFF8F8); // thẻ cảnh báo nhạt
  static const Color dangerBorder = Color(0xFFF2C4C6);
  static const Color dangerText = Color(0xFF8A1C21);
  static const Color inspectBorder = Color(0xFFE7B7D1);
  static const Color neutral = Color(0xFF6B6356);
  static const Color neutralBg = Color(0xFFEFEBE3);
  static const Color dotMuted = Color(0xFFBDB5A7);

  // Ô phòng ngừng phục vụ
  static const Color oosSurface = Color(0xFFF3F0EA);
  static const Color oosHatch = Color(0xFFDDD7CB);

  // Dòng thời gian trạng thái việc
  static const Color timelineLine = Color(0xFFDDD6C9);
  static const Color timelineRing = Color(0xFFCFC7B8);

  // Banner: chữ đậm hơn nền một bậc + viền
  static const Color infoText = Color(0xFF5A420E);
  static const Color infoBorder = Color(0xFFE8D6A8);
  static const Color warnText = Color(0xFF7A2E10);
  static const Color warnBorder = Color(0xFFF0C3AE);
  static const Color successText = Color(0xFF1F5A22);
  static const Color successBorder = Color(0xFFBFDDC1);
}

/// Khoảng cách chuẩn — lưới 4px.
class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Thang chữ dùng chung. Font Be Vietnam Pro đến từ `textTheme` qua DefaultTextStyle,
/// nên các kiểu ở đây chỉ mang cỡ chữ; độ đậm/màu thêm bằng `.copyWith(…)`.
class AppText {
  static const TextStyle micro =
      TextStyle(fontSize: 11); // nhãn trong ô phòng, huy hiệu
  static const TextStyle caption = TextStyle(fontSize: 12);
  static const TextStyle overline =
      TextStyle(fontSize: 12.5); // đầu mục in hoa, dòng phụ
  static const TextStyle meta = TextStyle(fontSize: 13);
  static const TextStyle body = TextStyle(fontSize: 14);
  static const TextStyle bodyLg = TextStyle(fontSize: 15);
  static const TextStyle title = TextStyle(fontSize: 16);
  static const TextStyle titleLg = TextStyle(fontSize: 18);
  static const TextStyle headline = TextStyle(fontSize: 20);
  static const TextStyle headlineLg = TextStyle(fontSize: 22);
  static const TextStyle displaySm = TextStyle(fontSize: 24);
  static const TextStyle display = TextStyle(fontSize: 28);
  static const TextStyle hero = TextStyle(fontSize: 40);

  /// Đầu cột bảng (web).
  static const TextStyle tableHead = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted);
}

/// Theme sáng Material 3: Be Vietnam Pro, nút vàng, app bar espresso.
class AppTheme {
  /// Vùng chạm tối thiểu theo hướng dẫn Android.
  static const double minTouch = 48;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  /// Gắn Be Vietnam Pro lên [base] và tô chữ bằng [AppColors.text].
  static TextTheme _textTheme(TextTheme base) =>
      GoogleFonts.beVietnamProTextTheme(base)
          .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  /// Theme duy nhất của app. Không có theme tối.
  /// Side effect: [GoogleFonts] có thể tải font lần đầu (hành vi package), không gọi API nghiệp vụ.
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

    /// Viền ô nhập bo [radiusSm], màu [c], dày [w].
    OutlineInputBorder inputBorder(Color c, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      // Ô đang được chọn bằng phím Tab phải nhìn rõ (WCAG 2.4.7) — mặc định Material chỉ phủ mờ 10%.
      focusColor: AppColors.gold.withValues(alpha: .35),
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
          disabledForegroundColor: AppColors.iconMuted,
          elevation: 0,
          minimumSize: const Size(0, minTouch),
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
          disabledForegroundColor: AppColors.iconMuted,
          minimumSize: const Size(0, minTouch),
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
          minimumSize: const Size(0, minTouch),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldText,
          minimumSize: const Size(0, minTouch),
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
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.goldTint,
        selectedIconTheme: IconThemeData(color: AppColors.goldText),
        unselectedIconTheme: IconThemeData(color: AppColors.muted),
        selectedLabelTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.goldText),
        unselectedLabelTextStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
        labelType: NavigationRailLabelType.all,
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
