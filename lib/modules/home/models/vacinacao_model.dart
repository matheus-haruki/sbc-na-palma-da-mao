class VacinacaoModel {
  final int id;
  final String codigo;
  final String nome;
  final String enderecoCompleto;
  final String fone;
  final String quantidadeVacinas;
  final String imageUrl;

  final String descricao;

  VacinacaoModel({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.enderecoCompleto,
    required this.fone,
    required this.quantidadeVacinas,
    required this.imageUrl,
    required this.descricao,
  });

  factory VacinacaoModel.fromJson(Map<String, dynamic> json) {
    return VacinacaoModel(
      id: json['id'] ?? 0,
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      enderecoCompleto: json['enderecoCompleto'] ?? '',
      fone: json['fone'] ?? '',
      quantidadeVacinas: json['quantidadeVacinas']?.toString() ?? '0',
      imageUrl: json['imgUrl'] ?? '',
      descricao: json['descricao'] ?? '',
    );
  }
}
