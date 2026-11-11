import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/core/utils/cpf_validator.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_state.dart';
import 'package:palma_da_mao/modules/debitos_transito/repositories/transito_repository.dart';

class TransitoCubit extends Cubit<TransitoState> {
  final TransitoRepository _repository;

  TransitoCubit(this._repository) : super(TransitoInitial());

  Future<void> buscarDebitos(String cpf) async {
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (!CpfValidator.isValid(cpfLimpo)) {
      emit(TransitoError("Informe um CPF válido."));
      return;
    }
    
    emit(TransitoLoading());
    try {
      final debitos = await _repository.consultarDebitos(cpfLimpo);
      emit(TransitoSuccess(debitos));
    } catch (e, stacktrace) {
      debugPrint('Erro ao buscar débitos: $e');
      debugPrint(stacktrace.toString());
      
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceFirst('Exception: ', '');
      }
      
      emit(TransitoError(msg));
    }
  }
}
