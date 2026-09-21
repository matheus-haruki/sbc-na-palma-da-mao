import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_guia_state.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';
import 'package:palma_da_mao/modules/iptu/utils/pdf_generator_isolate.dart';

class IptuGuiaCubit extends Cubit<IptuGuiaState> {
  final IptuRepository _repository;

  IptuGuiaCubit(this._repository) : super(IptuGuiaInitial());

  void reset() => emit(IptuGuiaInitial());

  Future<void> emitirGuiaTotal(String lancamento) async {
    emit(IptuGuiaLoading('Buscando dados da guia total na prefeitura...'));
    try {
      final guia = await _repository.gerarBoletoTotal(lancamento);
      emit(IptuGuiaLoading('Gerando o documento PDF...'));
      final pdfBytes = await gerarPdfGuiaPagamento(guia);
      emit(IptuGuiaSuccess(guia: guia, pdfBytes: pdfBytes));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> emitirGuiaParcela(String lancamento, int parcela) async {
    emit(IptuGuiaLoading('Buscando dados do boleto da parcela $parcela...'));
    try {
      final guia = await _repository.gerarBoletoParcela(lancamento, parcela);
      emit(IptuGuiaLoading('Gerando o documento PDF...'));
      final pdfBytes = await gerarPdfGuiaPagamento(guia);
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
