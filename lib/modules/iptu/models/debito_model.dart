class DebitoModel {
  final String? lancamento;
  final String? vencimento;
  final double? valorAtual;
  final String? tipo;

  DebitoModel({
    this.lancamento,
    this.vencimento,
    this.valorAtual,
    this.tipo,
  });

  factory DebitoModel.fromJson(Map<String, dynamic> json) {
    return DebitoModel(
      lancamento: json['lancamento'] as String?,
      vencimento: json['vencimento'] as String?,
      valorAtual: (json['valorAtual'] as num?)?.toDouble(),
      tipo: json['tipo'] as String?,
    );
  }
}
