import 'package:palma_da_mao/modules/iptu/models/debito_model.dart';

abstract class IptuState {}

class IptuInitial extends IptuState {}

class IptuLoading extends IptuState {}

class IptuSuccess extends IptuState {
  final List<DebitoModel> debitos;

  IptuSuccess(this.debitos);
}

class IptuError extends IptuState {
  final String message;

  IptuError(this.message);
}
