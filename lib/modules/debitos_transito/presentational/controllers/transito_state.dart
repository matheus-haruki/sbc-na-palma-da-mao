import 'package:palma_da_mao/modules/debitos_transito/models/debito_model.dart';

abstract class TransitoState {}

class TransitoInitial extends TransitoState {}

class TransitoLoading extends TransitoState {}

class TransitoSuccess extends TransitoState {
  final List<DebitoModel> debitos;

  TransitoSuccess(this.debitos);
}

class TransitoError extends TransitoState {
  final String message;

  TransitoError(this.message);
}
