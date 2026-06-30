import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> carregarDashboard() async {
    emit(HomeLoading());
    // Mock temporário para evitar erro de compilação sem a camada de domínio
    await Future.delayed(const Duration(seconds: 1));
    emit(HomeSuccess(atalhos: ['IPTU', 'Agendamentos', 'Multas']));
  }
}