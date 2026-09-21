import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/home/repositories/vacinacao_repository.dart';
import 'vacinacao_state.dart';

class VacinacaoCubit extends Cubit<VacinacaoState> {
  final VacinacaoRepository _repository;

  VacinacaoCubit(this._repository) : super(VacinacaoInitial());

  Future<void> fetchDados() async {
    emit(VacinacaoLoading());
    try {
      final dados = await _repository.fetchVacinacoes();
      emit(VacinacaoSuccess(dados));
    } catch (e) {
      emit(VacinacaoError(e.toString()));
    }
  }
}
