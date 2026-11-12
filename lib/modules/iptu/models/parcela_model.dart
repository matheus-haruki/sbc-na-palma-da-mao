import 'package:intl/intl.dart';

enum ParcelaStatus { paga, emAberto, vencida }

class ParcelaModel {
  final int? numeroParcela;
  final DateTime? dataVencimento;
  final DateTime? dataPagamento;
  final double valor;
  final ParcelaStatus status;

  ParcelaModel({
    required this.numeroParcela,
    required this.dataVencimento,
    required this.dataPagamento,
    required this.valor,
    required this.status,
  });

  factory ParcelaModel.fromJson(Map<String, dynamic> json, {DateTime? currentDate}) {
    // Tratamento de Datas
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      final cleanStr = dateStr.trim();
      if (cleanStr.isEmpty) return null;
      try {
        if (cleanStr.contains('/')) {
          return DateFormat('dd/MM/yyyy').parse(cleanStr);
        }
        return DateTime.tryParse(cleanStr);
      } catch (_) {
        return null;
      }
    }

    final dataVencimento = parseDate(json['dataDeVencimento']);
    final dataPagamento = parseDate(json['dataDePagamento']);
    
    // Extração do valor bruto (double) a partir de valorAtualizado
    double valor = 0.0;
    if (json['valorAtualizado'] != null && json['valorAtualizado']['valor'] != null) {
      final valorStr = json['valorAtualizado']['valor'].toString();
      valor = double.tryParse(valorStr) ?? 0.0;
    }

    // Tratamento de Status
    final statusStr = json['statusDePagamento']?.toString().trim().toUpperCase();
    ParcelaStatus status;

    if (statusStr != null && (statusStr.startsWith('PAG') || statusStr.startsWith('LIQUID'))) {
      status = ParcelaStatus.paga;
    } else {
      if (dataVencimento != null) {
        final now = currentDate ?? DateTime.now();
        final hoje = DateTime(now.year, now.month, now.day);
        final vencimentoSemHora = DateTime(
          dataVencimento.year,
          dataVencimento.month,
          dataVencimento.day,
        );

        // A parcela só é considerada vencida se o dia de vencimento for estritamente anterior a hoje.
        // Se vencer hoje, ainda está no prazo de pagamento e deve constar como em aberto.
        if (vencimentoSemHora.isBefore(hoje)) {
          status = ParcelaStatus.vencida;
        } else {
          status = ParcelaStatus.emAberto;
        }
      } else {
        status = ParcelaStatus.emAberto;
      }
    }

    return ParcelaModel(
      numeroParcela: json['numero'] as int?,
      dataVencimento: dataVencimento,
      dataPagamento: dataPagamento,
      valor: valor,
      status: status,
    );
  }
}
