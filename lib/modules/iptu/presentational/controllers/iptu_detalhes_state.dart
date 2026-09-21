import 'package:palma_da_mao/modules/iptu/models/parcela_model.dart';

abstract class IptuDetalhesState {}

class IptuDetalhesInitial extends IptuDetalhesState {}

class IptuDetalhesLoading extends IptuDetalhesState {}

class IptuDetalhesSuccess extends IptuDetalhesState {
  final List<ParcelaModel> parcelasPagas;
  final ParcelaModel? proximaParcela;
  final List<ParcelaModel> parcelasFuturas;
  final List<ParcelaModel> parcelasVencidas;

  IptuDetalhesSuccess({
    required this.parcelasPagas,
    required this.proximaParcela,
    required this.parcelasFuturas,
    required this.parcelasVencidas,
  });
}

class IptuDetalhesError extends IptuDetalhesState {
  final String message;
  IptuDetalhesError(this.message);
}
