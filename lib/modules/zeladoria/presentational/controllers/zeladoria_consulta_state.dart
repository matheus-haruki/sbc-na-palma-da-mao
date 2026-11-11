import '../../models/solicitacao_resumo_model.dart';

abstract class ZeladoriaConsultaState {}

class ZeladoriaConsultaInitial extends ZeladoriaConsultaState {}

class ZeladoriaConsultaLoading extends ZeladoriaConsultaState {}

class ZeladoriaConsultaSuccess extends ZeladoriaConsultaState {
  final List<SolicitacaoResumoModel> solicitacoes;
  final int totalElements;

  ZeladoriaConsultaSuccess({
    required this.solicitacoes,
    required this.totalElements,
  });
}

class ZeladoriaConsultaEmpty extends ZeladoriaConsultaState {}

class ZeladoriaConsultaError extends ZeladoriaConsultaState {
  final String message;

  ZeladoriaConsultaError(this.message);
}
