import '../../../../core/network/http_client.dart';
import '../../../../core/network/websocket_client.dart';
import '../../domain/models/message_model.dart';
import '../../domain/models/ticket_model.dart';

class ChatRepository {
  final IHttpClient _httpClient;
  final IWebSocketClient _webSocketClient;
  
  // Substitua pelas URLs do seu backend Spring Boot
  // NOTA: URL gerada pelo Ngrok. Mantém o app acessível de qualquer rede!
  final String _baseUrl = 'https://armband-appraiser-uneasy.ngrok-free.dev';
  final String _wsUrl = 'wss://armband-appraiser-uneasy.ngrok-free.dev/ws-atendimento/websocket'; // Endpoint exato do seu guia

  ChatRepository(this._httpClient, this._webSocketClient);

  // --- MÉTODOS HTTP ---

  // Chamado a cada 5 segundos pelo Cubit/Bloc (Polling)
  Future<List<TicketModel>> getTickets() async {
    final response = await _httpClient.get('$_baseUrl/api/tickets');
    if (response is List) {
      return response.map((e) => TicketModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<MessageModel>> getTicketHistory(String ticketId) async {
    final response = await _httpClient.get('$_baseUrl/api/tickets/$ticketId/mensagens');
    if (response is List) {
      return response.map((e) => MessageModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> sendMessageHttp(String ticketId, String text) async {
    await _httpClient.post(
      '$_baseUrl/api/tickets/$ticketId/mensagens', 
      data: {'conteudo': text},
    );
  }

  Future<void> finalizarTicket(String ticketId) async {
    await _httpClient.put('$_baseUrl/api/tickets/$ticketId/finalizar');
  }

  // --- MÉTODOS WEBSOCKET ---

  void connectWebSocket({void Function()? onConnect}) {
    _webSocketClient.connect(_wsUrl, onConnect: onConnect);
  }

  void disconnectWebSocket() {
    _webSocketClient.disconnect();
  }

  void subscribeToMessages(String ticketId, void Function(MessageModel) onMessageReceived) {
    _webSocketClient.subscribe(
      '/topic/tickets/$ticketId', 
      (dynamic messageData) {
        if (messageData is Map<String, dynamic>) {
          final message = MessageModel.fromJson(messageData);
          onMessageReceived(message);
        }
      }
    );
  }

  void sendMessageWs(String ticketId, String text) {
    // Exemplo de envio via STOMP, caso o backend suporte
    _webSocketClient.send(
      '/app/chat/$ticketId',
      body: '{"text": "$text"}',
    );
  }
}
