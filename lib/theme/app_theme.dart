import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color cream = Color(0xFFDDD7CC);
  static const Color paper = Color(0xFFFFFCF4);
  static const Color ink = Color(0xFF332719);
  static const Color gold = Color(0xFFB99043);
  static const Color goldDeep = Color(0xFF9A7026);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color whatsappDark = Color(0xFF1DA851);
}

class AppStrings {
  AppStrings._();

  static const String appTitle = 'دعوات الزفاف';
  static const String searchHint = 'ابحث عن اسم المدعو';
  static const String searchPrompt = 'اكتب اسم المدعو للبحث عن الدعوة';
  static const String notFound = 'لم يتم العثور على الاسم';
  static const String loading = 'جاري تحميل الدعوات...';
  static const String loadError = 'تعذر تحميل قائمة المدعوين';
  static const String shareWhatsApp = 'مشاركة عبر واتساب';
  static const String shareInvitation = 'مشاركة الدعوة';
  static const String back = 'رجوع';
  static const String guestMissing = 'تعذر العثور على الدعوة';
  static const String shareError = 'تعذر مشاركة الدعوة';
  static const String shareFallback =
      'تم حفظ صورة الدعوة. يمكنك إرفاقها يدويًا في واتساب.';
  static const String whatsappMessage =
      'السلام عليكم،\nيسرنا دعوتكم لحضور حفل زفاف الدكتور علي محمد حلبي.\nنتشرف بحضوركم 🌹';
}

class AppTheme {
  AppTheme._();

  static ThemeData theme() {
    const textTheme = TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Tajawal', color: AppColors.ink),
      bodyMedium: TextStyle(fontFamily: 'Tajawal', color: AppColors.ink),
      titleLarge: TextStyle(
        fontFamily: 'Tajawal',
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Tajawal',
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.light,
        surface: AppColors.cream,
        primary: AppColors.goldDeep,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.86),
        hintStyle: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.ink.withValues(alpha: 0.45),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.goldDeep, width: 1.6),
        ),
      ),
    );
  }
}
