class NovaSolicitacaoDto {
  final int bairroId;
  final String descricaoOcorrencia;
  final String? cepOcorrencia;
  final String logradouroOcorrencia;
  final String celularMunicipe;
  final String numeroOcorrencia;
  final String cpfMunicipe;
  final String nomeMunicipe;
  final int servicoId;

  NovaSolicitacaoDto({
    required this.bairroId,
    required this.descricaoOcorrencia,
    this.cepOcorrencia,
    required this.logradouroOcorrencia,
    required this.celularMunicipe,
    required this.numeroOcorrencia,
    required this.cpfMunicipe,
    required this.nomeMunicipe,
    required this.servicoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bairroId': bairroId,
      'descricaoOcorrencia': descricaoOcorrencia,
      'cepOcorrencia':
          (cepOcorrencia != null && cepOcorrencia!.trim().isNotEmpty)
              ? cepOcorrencia!.replaceAll(RegExp(r'[^0-9]'), '')
              : null,
      'logradouroOcorrencia': logradouroOcorrencia,
      'celularMunicipe': celularMunicipe.replaceAll(RegExp(r'[^0-9]'), ''),
      'numeroOcorrencia': numeroOcorrencia,
      'cpfMunicipe': cpfMunicipe.replaceAll(RegExp(r'[^0-9]'), ''),
      'nomeMunicipe': nomeMunicipe,
      'servicoId': servicoId,
    };
  }
}
