// lib/modules/home/presentational/controllers/home_state.dart
sealed class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

// Criamos uma classe modelo simples para segurar os dados combinados
class AtalhoModel {
  final String titulo;
  final String iconePath;

  AtalhoModel({required this.titulo, required this.iconePath});
}

class HomeSuccess extends HomeState {
  final List<AtalhoModel> atalhos; // Agora é uma lista de objetos
  
  HomeSuccess({required this.atalhos});
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}