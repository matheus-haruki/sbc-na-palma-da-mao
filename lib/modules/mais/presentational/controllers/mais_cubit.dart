import 'package:flutter_bloc/flutter_bloc.dart';
import 'mais_state.dart';

class MaisCubit extends Cubit<MaisState> {
  MaisCubit() : super(MaisInitial());

  void carregarConfiguracoes() {
    emit(MaisLoading());
    emit(MaisSuccess(isDarkMode: false));
  }

  void toggleTheme(bool value) {
    if (state is MaisSuccess) {
      emit(MaisSuccess(isDarkMode: value));
    }
  }
}
