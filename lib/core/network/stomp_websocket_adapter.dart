import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'websocket_client.dart';

class StompWebSocketAdapter implements IWebSocketClient {
  StompClient? _stompClient;

  @override
  void connect(String url, {Map<String, String>? headers, void Function()? onConnect}) {
    if (_stompClient != null && _stompClient!.isActive) {
      return; // Já conectado
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (StompFrame frame) {
          if (onConnect != null) {
            onConnect();
          }
        },
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        onWebSocketError: (dynamic error) => debugPrint(error.toString()),
        onStompError: (StompFrame frame) => debugPrint('Stomp error: \${frame.body}'),
        onDisconnect: (StompFrame frame) => debugPrint('Disconnected'),
      ),
    );
    _stompClient?.activate();
  }

  @override
  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  @override
  void subscribe(String destination, void Function(dynamic message) callback) {
    if (_stompClient == null) {
      throw Exception('StompClient não está inicializado. Chame connect() primeiro.');
    }
    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final jsonMap = json.decode(frame.body!);
            callback(jsonMap);
          } catch (e) {
            callback(frame.body); // Caso não seja JSON, retorna a string pura
          }
        }
      },
    );
  }

  @override
  void send(String destination, {String? body, Map<String, String>? headers}) {
    if (_stompClient == null) {
      throw Exception('StompClient não está inicializado. Chame connect() primeiro.');
    }
    _stompClient!.send(
      destination: destination,
      body: body,
      headers: headers,
    );
  }

  @override
  bool get isConnected => _stompClient?.isActive ?? false;
}
