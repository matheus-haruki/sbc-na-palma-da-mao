class BairroModel {
  final int bairroId;
  final String nomeBairro;

  BairroModel({
    required this.bairroId,
    required this.nomeBairro,
  });

  factory BairroModel.fromJson(Map<String, dynamic> json) {
    return BairroModel(
      bairroId: json['bairroId'] as int? ?? 0,
      nomeBairro: json['nomeBairro'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bairroId': bairroId,
      'nomeBairro': nomeBairro,
    };
  }
}
