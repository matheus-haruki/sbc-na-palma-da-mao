import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/theme/app_theme_controller.dart';

abstract class AppColors {
  static bool get _isDark {
    final mode = AppThemeController.instance.themeMode;
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }

  // Cores de Marca
  static Color get primary => const Color(0xFFFF8200);
  static Color get secondary => _isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1F3A5F);

  // Cores de Fundo e Superfície
  static Color get background => _isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA); // Pure Black
  static Color get surface => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA); // Dark Gray cards
  static Color get backgroundBlue => _isDark ? const Color(0xFF242424) : const Color(0xFFEEF4FD);
  static Color get backgroundGray => _isDark ? const Color(0xFF121212) : const Color(0xFFE1E3E4);
  static Color get white => const Color(0xFFFFFFFF);
  static Color get darkBlue => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF003E6F); // Used as strong color for text/icons
  static Color get gradientBlueStart => _isDark ? const Color(0xFF000000) : const Color(0xFF1F3A5F); // Pitch black gradient
  static Color get gradientBlueEnd => _isDark ? const Color(0xFF121212) : const Color(0xFF3C91D0); // Dark grey gradient
  static Color get lightBlue => _isDark ? const Color(0xFF2A2A2A) : const Color(0x33A5CBFF);
  static Color get shadow => _isDark ? const Color(0x00000000) : const Color(0x0C000000); // Remove shadow on pitch black
  static Color get border => _isDark ? const Color(0xFF333333) : const Color(0xFFC1C7D2);
  static Color get inactiveIndicator => _isDark ? const Color(0xFF333333) : const Color(0xFFE3E5E5);
  static Color get lightRed => _isDark ? const Color(0x4CFF6B6B) : const Color(0x4CFF9A8F);

  // Cores de Texto
  static Color get textPrimary => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212529); // White text
  static Color get textSecondary => _isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6C757D); // Grey text
  static Color get textLabel => _isDark ? const Color(0xFFE0E0E0) : const Color(0xFF151C22);

  // Cores de Feedback (Erros, Sucesso, Alertas)
  static Color get error => _isDark ? const Color(0xFFFF453A) : const Color(0xFFDC3545);
  static Color get success => _isDark ? const Color(0xFF32D74B) : const Color(0xFF198754);
  static Color get warning => _isDark ? const Color(0xFFFFD60A) : const Color(0xFFFFC107);
}
