import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/core/utils/cpf_validator.dart';
import '../../repositories/zeladoria_repository.dart';
import 'zeladoria_consulta_state.dart';

class ZeladoriaConsultaCubit extends Cubit<ZeladoriaConsultaState> {
  final ZeladoriaRepository _repository;

  ZeladoriaConsultaCubit(this._repository) : super(ZeladoriaConsultaInitial());

  Future<void> consultarPorCpf(String cpf) async {
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (!CpfValidator.isValid(cpfLimpo)) {
      emit(ZeladoriaConsultaError('Informe um CPF válido.'));
      return;
    }

    emit(ZeladoriaConsultaLoading());

    try {
      final response = await _repository.consultarSolicitacoes(
        cpfMunicipe: cpfLimpo,
      );

      if (response.content.isEmpty) {
        emit(ZeladoriaConsultaEmpty());
      } else {
        emit(
          ZeladoriaConsultaSuccess(
            solicitacoes: response.content,
            totalElements: response.totalElements,
          ),
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(ZeladoriaConsultaError(msg));
    }
  }
}
