abstract class IWebSocketClient {
  void connect(String url, {Map<String, String>? headers, void Function()? onConnect});
  void disconnect();
  void subscribe(String destination, void Function(dynamic message) callback);
  void send(String destination, {String? body, Map<String, String>? headers});
  bool get isConnected;
}
