import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/core/theme/app_theme_controller.dart';
import 'mais_state.dart';

class MaisCubit extends Cubit<MaisState> {
  MaisCubit() : super(MaisInitial());

  void carregarConfiguracoes() {
    emit(MaisLoading());
    final isDarkMode = AppThemeController.instance.themeMode == ThemeMode.dark;
    emit(MaisSuccess(isDarkMode: isDarkMode));
  }

  Future<void> setTheme(ThemeMode mode) async {
    await AppThemeController.instance.setThemeMode(mode);
    emit(MaisSuccess(isDarkMode: mode == ThemeMode.dark));
  }

  Future<void> toggleTheme(bool value) async {
    await setTheme(value ? ThemeMode.dark : ThemeMode.light);
  }
}
