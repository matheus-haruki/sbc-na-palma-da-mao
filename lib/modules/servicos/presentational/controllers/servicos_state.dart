sealed class ServicosState {}

class ServicosInitial extends ServicosState {}

class ServicosLoading extends ServicosState {}

class ServicosSuccess extends ServicosState {
  // Mais tarde, trocaremos String por uma Entity real de Serviço
  final List<String> categorias; 
  ServicosSuccess({required this.categorias});
}

class ServicosError extends ServicosState {
  final String message;
  ServicosError({required this.message});
}