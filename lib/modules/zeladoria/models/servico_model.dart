class ServicoModel {
  final int servicoId;
  final String nomeServico;

  ServicoModel({
    required this.servicoId,
    required this.nomeServico,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) {
    return ServicoModel(
      servicoId: json['servicoId'] as int? ?? 0,
      nomeServico: json['nomeServico'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'servicoId': servicoId,
      'nomeServico': nomeServico,
    };
  }
}
