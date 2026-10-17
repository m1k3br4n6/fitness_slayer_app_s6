import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized ThemeData based off a fantasy/pixelated palette
class AppTheme {
  static ThemeData get darkForgeTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.slateBackdrop,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.hearthPanel,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.parchmentWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.gemGold),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.hearthPanel,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.woodFrame, width: 1),
        ),
      ),

      // NavigationBar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.hearthPanel,
        indicatorColor: AppColors.flameOrange,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.brassBorder, fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.parchmentWhite);
          }
          return const IconThemeData(color: AppColors.brassBorder);
        }),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.flameOrange,
        foregroundColor: AppColors.parchmentWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.flameOrange,
        secondary: AppColors.gemGold,
        surface: AppColors.hearthPanel,
        onSurface: AppColors.parchmentWhite,
      ),
    );
  }
}