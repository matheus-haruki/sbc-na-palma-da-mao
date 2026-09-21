import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/message_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final String ticketId;

  ChatCubit(this._repository, {required this.ticketId}) : super(ChatInitial());

  void initChat() async {
    emit(ChatLoading());
    try {
      // 1. Busca histórico HTTP
      final history = await _repository.getTicketHistory(ticketId);
      emit(ChatLoaded(history));

      // 2. Conecta ao WebSocket
      _repository.connectWebSocket(onConnect: () {
        // 3. Ao conectar, se inscreve para ouvir novas mensagens
        _repository.subscribeToMessages(ticketId, _onNewMessage);
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onNewMessage(MessageModel message) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedList = List<MessageModel>.from(currentState.messages)..add(message);
      emit(ChatLoaded(updatedList));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Opcional: Adicionar mensagem localmente para feedback otimista
    // _onNewMessage(MessageModel(id: 'temp', text: text, sender: 'Eu', timestamp: DateTime.now()));

    try {
      // Pode enviar via HTTP ou WebSocket, dependendo da sua arquitetura
      await _repository.sendMessageHttp(ticketId, text);
    } catch (e) {
      // Lidar com erro de envio
    }
  }

  Future<void> finalizarTicket() async {
    try {
      await _repository.finalizarTicket(ticketId);
    } catch (e) {
      // Opcional: emitir erro se falhar
    }
  }

  @override
  Future<void> close() {
    _repository.disconnectWebSocket();
    return super.close();
  }
}
