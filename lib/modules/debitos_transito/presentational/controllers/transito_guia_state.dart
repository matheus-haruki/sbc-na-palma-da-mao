import 'dart:typed_data';
import 'package:palma_da_mao/modules/debitos_transito/models/guia_pagamento_model.dart';

abstract class TransitoGuiaState {}

class TransitoGuiaInitial extends TransitoGuiaState {}

class TransitoGuiaLoading extends TransitoGuiaState {
  final String mensagem;
  TransitoGuiaLoading(this.mensagem);
}

class TransitoGuiaSuccess extends TransitoGuiaState {
  final GuiaPagamentoModel guia;
  final Uint8List? pdfBytes;

  TransitoGuiaSuccess({required this.guia, this.pdfBytes});
}

class TransitoGuiaError extends TransitoGuiaState {
  final String message;
  TransitoGuiaError(this.message);
}
