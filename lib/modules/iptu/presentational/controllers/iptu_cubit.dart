import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_state.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';

class IptuCubit extends Cubit<IptuState> {
  final IptuRepository _repository;

  IptuCubit(this._repository) : super(IptuInitial());

  Future<void> buscarDebitos(String cpf) async {
    if (cpf.isEmpty) {
      emit(IptuError("O CPF não pode estar vazio."));
      return;
    }
    
    emit(IptuLoading());
    try {
      final debitos = await _repository.consultarDebitos(cpf);
      emit(IptuSuccess(debitos));
    } catch (e, stacktrace) {
      print('Erro ao buscar débitos: $e');
      print(stacktrace);
      
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceFirst('Exception: ', '');
      }
      
      emit(IptuError(msg));
    }
  }
}
