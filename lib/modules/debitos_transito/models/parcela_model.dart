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

  factory ParcelaModel.fromJson(Map<String, dynamic> json) {
    // Tratamento de Datas
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      final cleanStr = dateStr.trim();
      if (cleanStr.isEmpty) return null;
      try {
        return DateFormat('dd/MM/yyyy').parse(cleanStr);
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

    if (statusStr != null && statusStr.startsWith('PAGO')) {
      status = ParcelaStatus.paga;
    } else {
      if (dataVencimento != null && dataVencimento.isBefore(DateTime.now())) {
        status = ParcelaStatus.vencida;
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
