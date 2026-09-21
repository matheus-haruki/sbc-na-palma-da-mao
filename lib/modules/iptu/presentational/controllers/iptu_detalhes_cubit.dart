import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/iptu/models/parcela_model.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_detalhes_state.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';

class IptuDetalhesCubit extends Cubit<IptuDetalhesState> {
  final IptuRepository _repository;

  IptuDetalhesCubit(this._repository) : super(IptuDetalhesInitial());

  Future<void> buscarDetalhes(String lancamento) async {
    emit(IptuDetalhesLoading());
    try {
      final detalhes = await _repository.consultarDetalhes(lancamento);
      
      final listaRaw = detalhes['parcelas'] as List? ?? [];
      final todasParcelas = listaRaw.map((e) => ParcelaModel.fromJson(e)).toList();

      // Filtragem
      final parcelasPagas = todasParcelas.where((p) => p.status == ParcelaStatus.paga).toList();
      final parcelasVencidas = todasParcelas.where((p) => p.status == ParcelaStatus.vencida).toList();
      
      final emAberto = todasParcelas.where((p) => p.status == ParcelaStatus.emAberto).toList();
      
      // Ordena as em aberto pela data de vencimento
      emAberto.sort((a, b) {
        if (a.dataVencimento == null || b.dataVencimento == null) return 0;
        return a.dataVencimento!.compareTo(b.dataVencimento!);
      });

      ParcelaModel? proximaParcela;
      List<ParcelaModel> parcelasFuturas = [];

      if (emAberto.isNotEmpty) {
        proximaParcela = emAberto.first;
        if (emAberto.length > 1) {
          parcelasFuturas = emAberto.sublist(1);
        }
      }

      emit(IptuDetalhesSuccess(
        parcelasPagas: parcelasPagas,
        proximaParcela: proximaParcela,
        parcelasFuturas: parcelasFuturas,
        parcelasVencidas: parcelasVencidas,
      ));
    } catch (e, stacktrace) {
      debugPrint('Erro ao buscar detalhes do lançamento: $e');
      debugPrint(stacktrace.toString());
      
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceFirst('Exception: ', '');
      }
      
      emit(IptuDetalhesError(msg));
    }
  }
}
