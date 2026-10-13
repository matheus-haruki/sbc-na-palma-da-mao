import 'package:palma_da_mao/modules/debitos_transito/models/parcela_model.dart';

abstract class TransitoDetalhesState {}

class TransitoDetalhesInitial extends TransitoDetalhesState {}

class TransitoDetalhesLoading extends TransitoDetalhesState {}

class TransitoDetalhesSuccess extends TransitoDetalhesState {
  final List<ParcelaModel> parcelasPagas;
  final ParcelaModel? proximaParcela;
  final List<ParcelaModel> parcelasFuturas;
  final List<ParcelaModel> parcelasVencidas;

  TransitoDetalhesSuccess({
    required this.parcelasPagas,
    required this.proximaParcela,
    required this.parcelasFuturas,
    required this.parcelasVencidas,
  });
}

class TransitoDetalhesError extends TransitoDetalhesState {
  final String message;
  TransitoDetalhesError(this.message);
}
