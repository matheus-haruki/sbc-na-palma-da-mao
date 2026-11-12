import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/modules/iptu/models/parcela_model.dart';

void main() {
  group('ParcelaModel - Tratamento de Vencimento e Status', () {
    final referenceDate = DateTime(2026, 11, 12, 14, 30); // 12 de Novembro de 2026 às 14h30

    test('parcela com vencimento no dia de hoje deve ter status emAberto (não vencida)', () {
      final json = {
        'numero': 11,
        'dataDeVencimento': '12/11/2026',
        'statusDePagamento': 'EM ABERTO',
        'valorAtualizado': {'valor': '185.50'},
      };

      final parcela = ParcelaModel.fromJson(json, currentDate: referenceDate);

      expect(parcela.status, ParcelaStatus.emAberto);
      expect(parcela.numeroParcela, 11);
      expect(parcela.valor, 185.50);
      expect(parcela.dataVencimento, DateTime(2026, 11, 12));
    });

    test('parcela com vencimento anterior ao dia de hoje deve ter status vencida', () {
      final json = {
        'numero': 10,
        'dataDeVencimento': '11/11/2026',
        'statusDePagamento': 'EM ABERTO',
        'valorAtualizado': {'valor': '185.50'},
      };

      final parcela = ParcelaModel.fromJson(json, currentDate: referenceDate);

      expect(parcela.status, ParcelaStatus.vencida);
    });

    test('parcela com vencimento futuro deve ter status emAberto', () {
      final json = {
        'numero': 12,
        'dataDeVencimento': '12/12/2026',
        'statusDePagamento': 'EM ABERTO',
        'valorAtualizado': {'valor': '185.50'},
      };

      final parcela = ParcelaModel.fromJson(json, currentDate: referenceDate);

      expect(parcela.status, ParcelaStatus.emAberto);
    });

    test('parcela com statusDePagamento PAGO deve ter status paga mesmo com data vencida', () {
      final json = {
        'numero': 9,
        'dataDeVencimento': '12/09/2026',
        'dataDePagamento': '10/09/2026',
        'statusDePagamento': 'PAGO',
        'valorAtualizado': {'valor': '185.50'},
      };

      final parcela = ParcelaModel.fromJson(json, currentDate: referenceDate);

      expect(parcela.status, ParcelaStatus.paga);
      expect(parcela.dataPagamento, DateTime(2026, 9, 10));
    });

    test('suporta datas em formato ISO (yyyy-MM-dd)', () {
      final json = {
        'numero': 11,
        'dataDeVencimento': '2026-11-12',
        'statusDePagamento': 'EM ABERTO',
        'valorAtualizado': {'valor': '150.00'},
      };

      final parcela = ParcelaModel.fromJson(json, currentDate: referenceDate);

      expect(parcela.status, ParcelaStatus.emAberto);
      expect(parcela.dataVencimento, DateTime(2026, 11, 12));
    });
  });
}
