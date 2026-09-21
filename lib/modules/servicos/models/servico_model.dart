enum ServicoType {
  web,
  native,
  group;

  static ServicoType fromString(String value) {
    return ServicoType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ServicoType.web,
    );
  }
}

class ServicoModel {
  final String id;
  final String title;
  final String categoria;
  final ServicoType type;
  final String url;
  final String route;
  final bool isAvailable;
  final List<ServicoModel> subItems;

  const ServicoModel({
    required this.id,
    required this.title,
    required this.categoria,
    required this.type,
    this.url = '',
    this.route = '',
    this.isAvailable = true,
    this.subItems = const [],
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) {
    return ServicoModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      categoria: json['categoria'] ?? '',
      type: ServicoType.fromString(json['type'] ?? ''),
      url: json['url'] ?? '',
      route: json['route'] ?? '',
      isAvailable: json['is_available'] ?? true,
      subItems: json['sub_items'] != null
          ? List<ServicoModel>.from(
              json['sub_items'].map((x) => ServicoModel.fromJson(x)),
            )
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'url': url,
      'route': route,
      'is_available': isAvailable,
      'sub_items': subItems.map((x) => x.toJson()).toList(),
    };
  }
}
