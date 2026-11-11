import 'solicitacao_resumo_model.dart';

class ConsultaSolicitacoesResponse {
  final List<SolicitacaoResumoModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;

  ConsultaSolicitacoesResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
  });

  factory ConsultaSolicitacoesResponse.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    final content = rawContent
        .map((e) => SolicitacaoResumoModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pageInfo = json['page'] as Map<String, dynamic>? ?? {};

    return ConsultaSolicitacoesResponse(
      content: content,
      pageSize: pageInfo['size'] as int? ?? 10,
      pageNumber: pageInfo['number'] as int? ?? 0,
      totalElements: pageInfo['totalElements'] as int? ?? content.length,
      totalPages: pageInfo['totalPages'] as int? ?? 1,
    );
  }
}
