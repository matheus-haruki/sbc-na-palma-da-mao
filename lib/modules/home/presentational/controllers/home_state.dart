sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<String> atalhos;
  
  HomeSuccess({required this.atalhos});
}

class HomeError extends HomeState {
  final String message;
  
  HomeError({required this.message});
}