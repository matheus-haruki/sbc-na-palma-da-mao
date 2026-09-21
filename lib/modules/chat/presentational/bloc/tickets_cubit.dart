import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final ChatRepository _repository;
  Timer? _pollingTimer;

  TicketsCubit(this._repository) : super(TicketsInitial());

  void carregarTickets() async {
    // Só emite loading na primeira vez, para não piscar a tela no polling
    if (state is! TicketsLoaded) {
      emit(TicketsLoading());
    }

    try {
      final tickets = await _repository.getTickets();
      emit(TicketsLoaded(tickets));
    } catch (e) {
      // Se falhar, avisa apenas se for a primeira carga. 
      // Se for no polling, podemos manter o estado antigo pra não interromper a UX.
      if (state is! TicketsLoaded) {
        emit(TicketsError(e.toString()));
      }
    }
  }

  void iniciarPolling() {
    // Faz a primeira carga
    carregarTickets();

    // Inicia o polling a cada 5 segundos
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      carregarTickets();
    });
  }

  void pararPolling() {
    _pollingTimer?.cancel();
  }

  @override
  Future<void> close() {
    pararPolling();
    return super.close();
  }
}
