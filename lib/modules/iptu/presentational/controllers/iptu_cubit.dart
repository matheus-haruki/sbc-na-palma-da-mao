import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/core/utils/cpf_validator.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_state.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';

class IptuCubit extends Cubit<IptuState> {
  final IptuRepository _repository;

  IptuCubit(this._repository) : super(IptuInitial());

  Future<void> buscarDebitos(String cpf) async {
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (!CpfValidator.isValid(cpfLimpo)) {
      emit(IptuError("Informe um CPF válido."));
      return;
    }
    
    emit(IptuLoading());
    try {
      final debitos = await _repository.consultarDebitos(cpfLimpo);
      emit(IptuSuccess(debitos));
    } catch (e, stacktrace) {
      debugPrint('Erro ao buscar débitos: $e');
      debugPrint(stacktrace.toString());
      
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceFirst('Exception: ', '');
      }
      
      emit(IptuError(msg));
    }
  }
}
