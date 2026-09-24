import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/theme/app_theme_controller.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        final themeMode = AppThemeController.instance.themeMode;

        return MaterialApp.router(
          title: 'SBC na Palma da Mão',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Parkinsans',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Parkinsans',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ).copyWith(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
              surfaceContainerHighest: AppColors.backgroundBlue,
              onSurface: AppColors.textPrimary,
              onPrimary: AppColors.textPrimary,
            ),
            dividerColor: Colors.white24,
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.white,
            ),
            useMaterial3: true,
          ),
          themeMode: themeMode,
          routerConfig: Modular.routerConfig,
        );
      },
    );
  }
}
