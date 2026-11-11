import 'dart:typed_data';
import '../../models/solicitacao_detalhe_model.dart';

abstract class ZeladoriaDetalhesState {}

class ZeladoriaDetalhesInitial extends ZeladoriaDetalhesState {}

class ZeladoriaDetalhesLoading extends ZeladoriaDetalhesState {}

class ZeladoriaDetalhesSuccess extends ZeladoriaDetalhesState {
  final SolicitacaoDetalheModel detalhe;
  final List<Uint8List> fotos;
  final bool carregandoFotos;

  ZeladoriaDetalhesSuccess(
    this.detalhe, {
    this.fotos = const [],
    this.carregandoFotos = false,
  });

  ZeladoriaDetalhesSuccess copyWith({
    SolicitacaoDetalheModel? detalhe,
    List<Uint8List>? fotos,
    bool? carregandoFotos,
  }) {
    return ZeladoriaDetalhesSuccess(
      detalhe ?? this.detalhe,
      fotos: fotos ?? this.fotos,
      carregandoFotos: carregandoFotos ?? this.carregandoFotos,
    );
  }
}

class ZeladoriaDetalhesError extends ZeladoriaDetalhesState {
  final String message;

  ZeladoriaDetalhesError(this.message);
}
