import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_guia_state.dart';
import 'package:palma_da_mao/modules/debitos_transito/repositories/transito_repository.dart';
import 'package:palma_da_mao/modules/debitos_transito/utils/pdf_generator_isolate.dart';

class TransitoGuiaCubit extends Cubit<TransitoGuiaState> {
  final TransitoRepository _repository;

  TransitoGuiaCubit(this._repository) : super(TransitoGuiaInitial());

  void reset() => emit(TransitoGuiaInitial());

  Future<void> emitirGuiaTotal(String lancamento) async {
    emit(TransitoGuiaLoading('Buscando dados da guia total na prefeitura...'));
    try {
      final guia = await _repository.gerarBoletoTotal(lancamento);
      emit(TransitoGuiaLoading('Gerando o documento PDF...'));
      final pdfBytes = await gerarPdfGuiaPagamento(guia);
      emit(TransitoGuiaSuccess(guia: guia, pdfBytes: pdfBytes));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> emitirGuiaParcela(String lancamento, int parcela) async {
    emit(TransitoGuiaLoading('Buscando dados do boleto da parcela $parcela...'));
    try {
      final guia = await _repository.gerarBoletoParcela(lancamento, parcela);
      emit(TransitoGuiaLoading('Gerando o documento PDF...'));
      final pdfBytes = await gerarPdfGuiaPagamento(guia);
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
