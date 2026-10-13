import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_state.dart';
import 'package:palma_da_mao/modules/debitos_transito/repositories/transito_repository.dart';

class TransitoCubit extends Cubit<TransitoState> {
  final TransitoRepository _repository;

  TransitoCubit(this._repository) : super(TransitoInitial());

  Future<void> buscarDebitos(String cpf) async {
    if (cpf.isEmpty) {
      emit(TransitoError("O CPF não pode estar vazio."));
      return;
    }
    
    emit(TransitoLoading());
    try {
      final debitos = await _repository.consultarDebitos(cpf);
      emit(TransitoSuccess(debitos));
    } catch (e, stacktrace) {
      print('Erro ao buscar débitos: $e');
      print(stacktrace);
      
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceFirst('Exception: ', '');
      }
      
      emit(TransitoError(msg));
    }
  }
}
