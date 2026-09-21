class TicketModel {
  final String id;
  final String title;
  final String status;
  
  TicketModel({
    required this.id,
    required this.title,
    required this.status,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final protocolo = json['protocolo'] ?? '';
    
    String municipeNome = 'Munícipe';
    if (json['municipe'] != null) {
      if (json['municipe'] is String) {
        municipeNome = json['municipe'];
      } else if (json['municipe'] is Map) {
        municipeNome = json['municipe']['nome'] ?? 'Munícipe';
      }
    }
    
    return TicketModel(
      id: json['id']?.toString() ?? '',
      title: 'Protocolo: $protocolo\n$municipeNome',
      status: json['status'] ?? 'Aberto',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}
