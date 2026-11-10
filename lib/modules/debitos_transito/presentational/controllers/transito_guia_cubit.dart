import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_guia_state.dart';
import 'package:palma_da_mao/modules/debitos_transito/repositories/transito_repository.dart';
import 'package:palma_da_mao/modules/debitos_transito/utils/pdf_generator_isolate.dart';

class TransitoGuiaCubit extends Cubit<TransitoGuiaState> {
  final TransitoRepository _repository;

  TransitoGuiaCubit(this._repository) : super(TransitoGuiaInitial());

  void reset() => emit(TransitoGuiaInitial());

  Future<void> emitirGuiaTotal(
    String lancamento, {
    Map<String, dynamic>? dadosComplementares,
    String? parcelasDescricao,
  }) async {
    emit(TransitoGuiaLoading('Buscando dados da guia total na prefeitura...'));
    try {
      final guia = await _repository.gerarBoletoTotal(
        lancamento,
        dadosComplementares: dadosComplementares,
        parcelasDescricao: parcelasDescricao,
      );
      emit(TransitoGuiaLoading('Gerando o documento PDF...'));
      Uint8List? pdfBytes;
      try {
        pdfBytes = await gerarPdfGuiaPagamento(guia);
      } catch (pdfError) {
        debugPrint('Erro ao gerar PDF da guia de trânsito: $pdfError');
      }
      emit(TransitoGuiaSuccess(guia: guia, pdfBytes: pdfBytes));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> emitirGuiaParcela(
    String lancamento, 
    int parcela, {
    Map<String, dynamic>? dadosComplementares,
    String? parcelasDescricao,
    String? valorEstimado,
  }) async {
    emit(TransitoGuiaLoading('Buscando dados do boleto da parcela $parcela...'));
    try {
      final guia = await _repository.gerarBoletoParcela(
        lancamento, 
        parcela,
        dadosComplementares: dadosComplementares,
        parcelasDescricao: parcelasDescricao,
        valorEstimado: valorEstimado,
      );
      emit(TransitoGuiaLoading('Gerando o documento PDF...'));
      Uint8List? pdfBytes;
      try {
        pdfBytes = await gerarPdfGuiaPagamento(guia);
      } catch (pdfError) {
        debugPrint('Erro ao gerar PDF da guia de trânsito: $pdfError');
      }
      emit(TransitoGuiaSuccess(guia: guia, pdfBytes: pdfBytes));
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    String msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.replaceFirst('Exception: ', '');
    }
    emit(TransitoGuiaError(msg));
  }
}
