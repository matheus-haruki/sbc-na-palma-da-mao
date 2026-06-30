import 'package:flutter_bloc/flutter_bloc.dart';
import 'servicos_state.dart';

class ServicosCubit extends Cubit<ServicosState> {
  ServicosCubit() : super(ServicosInitial());

  Future<void> carregarListaDeServicos() async {
    emit(ServicosLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simula API
    
    emit(ServicosSuccess(
      categorias: ['Saúde', 'Educação', 'Tributos', 'Mobilidade', 'Segurança'],
    ));
  }
}