import '../../domain/models/ticket_model.dart';

abstract class TicketsState {}

class TicketsInitial extends TicketsState {}

class TicketsLoading extends TicketsState {}

class TicketsLoaded extends TicketsState {
  final List<TicketModel> tickets;
  TicketsLoaded(this.tickets);
}

class TicketsError extends TicketsState {
  final String message;
  TicketsError(this.message);
}
