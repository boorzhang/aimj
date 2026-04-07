import 'package:flutter/material.dart';

/// 全局视觉规范 - 对齐 docs/2个关键交付UI和架构.md 11.1
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFFFF4D4F); // 高点击红
  static const Color accent = Color(0xFFFFD666); // 金色奖励
  static const Color background = Color(0xFF0F0F10);
  static const Color card = Color(0xFF1A1A1C);
  static const Color divider = Color(0xFF2A2A2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A8);

  /// 金色奖励渐变 - 用于激励解锁按钮
  static const LinearGradient rewardGradient = LinearGradient(
    colors: [Color(0xFFFFE27A), Color(0xFFFFB33A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadii {
  const AppRadii._();
  static const double card = 20;
  static const double button = 16;
  static const double dialog = 24;
}

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle pageTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle cta = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerColor: AppColors.divider,
      cardColor: AppColors.card,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
