class SolicitacaoDetalheModel {
  final String protocolo;
  final String nomeServico;
  final String rotuloStatus;
  final DateTime incluidoEm;
  final String descricaoOcorrencia;
  final String logradouroOcorrencia;
  final String numeroOcorrencia;
  final String bairroOcorrencia;
  final String cepOcorrencia;
  final int quantidadeFotos;
  final String? mensagemPublica;

  SolicitacaoDetalheModel({
    required this.protocolo,
    required this.nomeServico,
    required this.rotuloStatus,
    required this.incluidoEm,
    required this.descricaoOcorrencia,
    required this.logradouroOcorrencia,
    required this.numeroOcorrencia,
    required this.bairroOcorrencia,
    required this.cepOcorrencia,
    required this.quantidadeFotos,
    this.mensagemPublica,
  });

  factory SolicitacaoDetalheModel.fromJson(Map<String, dynamic> json) {
    return SolicitacaoDetalheModel(
      protocolo: json['protocolo'] as String? ?? '',
      nomeServico: json['nomeServico'] as String? ?? '',
      rotuloStatus: json['rotuloStatus'] as String? ?? 'Em análise',
      incluidoEm: json['incluidoEm'] != null
          ? DateTime.tryParse(json['incluidoEm'] as String) ?? DateTime.now()
          : DateTime.now(),
      descricaoOcorrencia: json['descricaoOcorrencia'] as String? ?? '',
      logradouroOcorrencia: json['logradouroOcorrencia'] as String? ?? '',
      numeroOcorrencia: json['numeroOcorrencia'] as String? ?? '',
      bairroOcorrencia: json['bairroOcorrencia'] as String? ?? '',
      cepOcorrencia: json['cepOcorrencia'] as String? ?? '',
      quantidadeFotos: json['quantidadeFotos'] as int? ?? 0,
      mensagemPublica: json['mensagemPublica'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocolo': protocolo,
      'nomeServico': nomeServico,
      'rotuloStatus': rotuloStatus,
      'incluidoEm': incluidoEm.toIso8601String(),
      'descricaoOcorrencia': descricaoOcorrencia,
      'logradouroOcorrencia': logradouroOcorrencia,
      'numeroOcorrencia': numeroOcorrencia,
      'bairroOcorrencia': bairroOcorrencia,
      'cepOcorrencia': cepOcorrencia,
      'quantidadeFotos': quantidadeFotos,
      if (mensagemPublica != null) 'mensagemPublica': mensagemPublica,
    };
  }
}
