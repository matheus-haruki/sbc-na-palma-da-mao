class CategoriaModel {
  final int categoriaId;
  final String nomeCategoria;

  CategoriaModel({
    required this.categoriaId,
    required this.nomeCategoria,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      categoriaId: json['categoriaId'] as int? ?? 0,
      nomeCategoria: json['nomeCategoria'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoriaId': categoriaId,
      'nomeCategoria': nomeCategoria,
    };
  }
}
