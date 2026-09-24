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
            scaffoldBackgroundColor: const Color(0xFF0B0B0D),
            fontFamily: 'Parkinsans',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.dark,
            ).copyWith(
              primary: Colors.white,
              secondary: Colors.white70,
              surface: const Color(0xFF1A1A1D),
              surfaceContainerHighest: const Color(0xFF2A2A2E),
              onSurface: Colors.white,
              onPrimary: Colors.black,
              onSecondary: Colors.black,
            ),
            cardColor: const Color(0xFF17171A),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1A1A1D),
            ),
            dividerColor: Colors.white12,
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0B0B0D),
              foregroundColor: Colors.white,
            ),
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Parkinsans',
              bodyColor: Colors.white,
              displayColor: Colors.white,
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
