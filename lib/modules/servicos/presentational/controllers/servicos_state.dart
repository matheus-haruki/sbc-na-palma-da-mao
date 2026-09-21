import 'package:palma_da_mao/modules/servicos/models/servico_model.dart';

sealed class ServicosState {}

class ServicosInitial extends ServicosState {}

class ServicosLoading extends ServicosState {}

class ServicosSuccess extends ServicosState {
  // Agora o estado carrega nossos modelos estruturados
  final List<ServicoModel> servicos;

  ServicosSuccess({required this.servicos});
}

class ServicosError extends ServicosState {
  final String message;

  ServicosError({required this.message});
}
