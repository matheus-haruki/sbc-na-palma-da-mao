// lib/modules/mais/presentational/controllers/mais_state.dart
sealed class MaisState {}

class MaisInitial extends MaisState {}
class MaisLoading extends MaisState {}
class MaisSuccess extends MaisState {
  final bool isDarkMode;
  MaisSuccess({required this.isDarkMode});
}