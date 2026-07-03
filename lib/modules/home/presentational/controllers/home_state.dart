// lib/modules/home/presentational/controllers/home_state.dart
sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

// Criamos uma classe modelo simples para segurar os dados combinados
class AtalhoModel {
  final String idCategoria;
  final String titulo;
  final String iconePath;
  final String? url;
  final String? rota;

  AtalhoModel({
    required this.idCategoria,
    required this.titulo,
    required this.iconePath,
    this.url,
    this.rota,
  });
}

class HomeSuccess extends HomeState {
  final List<AtalhoModel> atalhos;
  final List<AtalhoModel> maisUtilizados;

  HomeSuccess({required this.atalhos, required this.maisUtilizados});
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
