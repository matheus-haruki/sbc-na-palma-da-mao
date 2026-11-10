import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_guia_state.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';
import 'package:palma_da_mao/modules/iptu/utils/pdf_generator_isolate.dart';

class IptuGuiaCubit extends Cubit<IptuGuiaState> {
  final IptuRepository _repository;

  IptuGuiaCubit(this._repository) : super(IptuGuiaInitial());

  void reset() => emit(IptuGuiaInitial());

  Future<void> emitirGuiaTotal(
    String lancamento, {
    Map<String, dynamic>? dadosComplementares,
    String? parcelasDescricao,
  }) async {
    emit(IptuGuiaLoading('Buscando dados da guia total na prefeitura...'));
    try {
      final guia = await _repository.gerarBoletoTotal(
        lancamento,
        dadosComplementares: dadosComplementares,
        parcelasDescricao: parcelasDescricao,
      );
      emit(IptuGuiaLoading('Gerando o documento PDF...'));
      Uint8List? pdfBytes;
      try {
        pdfBytes = await gerarPdfGuiaPagamento(guia);
      } catch (pdfError) {
        debugPrint('Erro ao gerar PDF da guia IPTU: $pdfError');
      }
      emit(IptuGuiaSuccess(guia: guia, pdfBytes: pdfBytes));
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
    emit(IptuGuiaLoading('Buscando dados do boleto da parcela $parcela...'));
    try {
      final guia = await _repository.gerarBoletoParcela(
        lancamento, 
        parcela,
        dadosComplementares: dadosComplementares,
        parcelasDescricao: parcelasDescricao,
        valorEstimado: valorEstimado,
      );
      emit(IptuGuiaLoading('Gerando o documento PDF...'));
      Uint8List? pdfBytes;
      try {
        pdfBytes = await gerarPdfGuiaPagamento(guia);
      } catch (pdfError) {
        debugPrint('Erro ao gerar PDF da guia IPTU: $pdfError');
      }
      emit(IptuGuiaSuccess(guia: guia, pdfBytes: pdfBytes));
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    String msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.replaceFirst('Exception: ', '');
    }
    emit(IptuGuiaError(msg));
  }
}
