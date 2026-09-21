import 'package:palma_da_mao/modules/home/models/vacinacao_model.dart';

abstract class VacinacaoState {}

class VacinacaoInitial extends VacinacaoState {}

class VacinacaoLoading extends VacinacaoState {}

class VacinacaoSuccess extends VacinacaoState {
  final List<VacinacaoModel> dados;

  VacinacaoSuccess(this.dados);
}

class VacinacaoError extends VacinacaoState {
  final String message;

  VacinacaoError(this.message);
}
