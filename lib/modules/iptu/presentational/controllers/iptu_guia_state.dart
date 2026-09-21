import 'dart:typed_data';
import 'package:palma_da_mao/modules/iptu/models/guia_pagamento_model.dart';

abstract class IptuGuiaState {}

class IptuGuiaInitial extends IptuGuiaState {}

class IptuGuiaLoading extends IptuGuiaState {
  final String mensagem;
  IptuGuiaLoading(this.mensagem);
}

class IptuGuiaSuccess extends IptuGuiaState {
  final GuiaPagamentoModel guia;
  final Uint8List? pdfBytes;

  IptuGuiaSuccess({required this.guia, this.pdfBytes});
}

class IptuGuiaError extends IptuGuiaState {
  final String message;
  IptuGuiaError(this.message);
}
