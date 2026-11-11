import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/zeladoria_repository.dart';
import 'zeladoria_detalhes_state.dart';

class ZeladoriaDetalhesCubit extends Cubit<ZeladoriaDetalhesState> {
  final ZeladoriaRepository _repository;

  ZeladoriaDetalhesCubit(this._repository) : super(ZeladoriaDetalhesInitial());

  Future<void> buscarDetalhes({
    required String cpfMunicipe,
    required String protocolo,
  }) async {
    emit(ZeladoriaDetalhesLoading());

    try {
      final detalhe = await _repository.consultarDetalheSolicitacao(
        cpfMunicipe: cpfMunicipe,
        protocolo: protocolo,
      );

      final temFotos = detalhe.quantidadeFotos > 0 && cpfMunicipe.isNotEmpty;
      emit(
        ZeladoriaDetalhesSuccess(
          detalhe,
          carregandoFotos: temFotos,
        ),
      );

      if (temFotos) {
        final fotos = await _repository.buscarFotosSolicitacao(
          cpfMunicipe: cpfMunicipe,
          protocolo: protocolo,
          quantidadeFotos: detalhe.quantidadeFotos,
        );

        if (!isClosed) {
          emit(
            ZeladoriaDetalhesSuccess(
              detalhe,
              fotos: fotos,
              carregandoFotos: false,
            ),
          );
        }
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(ZeladoriaDetalhesError(msg));
    }
  }
}
