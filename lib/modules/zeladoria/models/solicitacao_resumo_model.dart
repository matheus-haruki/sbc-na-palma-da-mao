class SolicitacaoResumoModel {
  final String protocolo;
  final String nomeServico;
  final String rotuloStatus;
  final DateTime incluidoEm;

  SolicitacaoResumoModel({
    required this.protocolo,
    required this.nomeServico,
    required this.rotuloStatus,
    required this.incluidoEm,
  });

  factory SolicitacaoResumoModel.fromJson(Map<String, dynamic> json) {
    return SolicitacaoResumoModel(
      protocolo: json['protocolo'] as String? ?? '',
      nomeServico: json['nomeServico'] as String? ?? '',
      rotuloStatus: json['rotuloStatus'] as String? ?? 'Em análise',
      incluidoEm: json['incluidoEm'] != null
          ? DateTime.tryParse(json['incluidoEm'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocolo': protocolo,
      'nomeServico': nomeServico,
      'rotuloStatus': rotuloStatus,
      'incluidoEm': incluidoEm.toIso8601String(),
    };
  }
}
