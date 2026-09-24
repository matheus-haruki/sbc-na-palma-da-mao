import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/core/theme/app_theme_controller.dart';
import 'mais_state.dart';

class MaisCubit extends Cubit<MaisState> {
  MaisCubit() : super(MaisInitial());

  void carregarConfiguracoes() {
    emit(MaisLoading());
    emit(MaisSuccess(themeMode: AppThemeController.instance.themeMode));
  }

  void alterarTema(ThemeMode themeMode) {
    AppThemeController.instance.setThemeMode(themeMode);
    emit(MaisSuccess(themeMode: themeMode));
  }
}
