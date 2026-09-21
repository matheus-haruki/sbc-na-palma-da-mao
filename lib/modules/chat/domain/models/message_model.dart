class MessageModel {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      text: json['conteudo'] ?? '',
      sender: json['remetente'] ?? 'Desconhecido',
      timestamp: json['dataEnvio'] != null 
          ? DateTime.parse(json['dataEnvio']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
