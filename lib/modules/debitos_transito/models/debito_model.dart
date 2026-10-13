class DebitoModel {
  final String? lancamento;
  final String? vencimento;
  final double? valorAtual;
  final String? tipo;
  final String? placa;
  final String? renavam;
  final String? ait;

  DebitoModel({
    this.lancamento,
    this.vencimento,
    this.valorAtual,
    this.tipo,
    this.placa,
    this.renavam,
    this.ait,
  });

  factory DebitoModel.fromJson(Map<String, dynamic> json) {
    return DebitoModel(
      lancamento: json['lancamento'] as String?,
      vencimento: json['vencimento'] as String?,
      valorAtual: (json['valorAtual'] as num?)?.toDouble(),
      tipo: json['tipo'] as String?,
      placa: json['placa'] as String?,
      renavam: json['renavam'] as String?,
      ait: json['ait'] as String?,
    );
  }
}
