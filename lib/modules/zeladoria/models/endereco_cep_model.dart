class EnderecoCepModel {
  final String logradouro;
  final int bairroId;
  final String nomeBairro;

  EnderecoCepModel({
    required this.logradouro,
    required this.bairroId,
    required this.nomeBairro,
  });

  factory EnderecoCepModel.fromJson(Map<String, dynamic> json) {
    return EnderecoCepModel(
      logradouro: json['logradouro'] as String? ?? '',
      bairroId: json['bairroId'] as int? ?? 0,
      nomeBairro: json['nomeBairro'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logradouro': logradouro,
      'bairroId': bairroId,
      'nomeBairro': nomeBairro,
    };
  }
}
