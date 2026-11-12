import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:palma_da_mao/modules/iptu/models/debito_model.dart';
import 'package:palma_da_mao/modules/iptu/models/guia_pagamento_model.dart';
import 'package:palma_da_mao/modules/iptu/models/parcela_model.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_detalhes_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_detalhes_state.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';

class FakeIptuDetalhesRepository extends Fake implements IptuRepository {
  Map<String, dynamic> mockDetalhes = {};

  @override
  Future<Map<String, dynamic>> consultarDetalhes(String lancamento) async {
    return mockDetalhes;
  }

  @override
  Future<List<DebitoModel>> consultarDebitos(String cpf) async => [];

  @override
  Future<GuiaPagamentoModel> gerarBoletoTotal(
    String lancamento, {
    Map<String, dynamic>? dadosComplementares,
    String? parcelasDescricao,
  }) async => throw UnimplementedError();

  @override
  Future<GuiaPagamentoModel> gerarBoletoParcela(
    String lancamento,
    int parcela, {
    Map<String, dynamic>? dadosComplementares,
    String? parcelasDescricao,
    String? valorEstimado,
  }) async => throw UnimplementedError();
}

void main() {
  group('IptuDetalhesCubit - Parcela vencendo hoje', () {
    late FakeIptuDetalhesRepository fakeRepository;
    late IptuDetalhesCubit cubit;

    setUp(() {
      fakeRepository = FakeIptuDetalhesRepository();
      cubit = IptuDetalhesCubit(fakeRepository);
    });

    test('quando parcela vence no dia de hoje, não deve ser considerada em atraso e deve ser a proximaParcela', () async {
      final now = DateTime.now();
      final hojeStr = DateFormat('dd/MM/yyyy').format(now);
      final futuroStr = DateFormat('dd/MM/yyyy').format(now.add(const Duration(days: 30)));

      fakeRepository.mockDetalhes = {
        'parcelas': [
          {
            'numero': 10,
            'dataDeVencimento': '10/10/2026',
            'dataDePagamento': '09/10/2026',
            'statusDePagamento': 'PAGO',
            'valorAtualizado': {'valor': '120.00'},
          },
          {
            'numero': 11,
            'dataDeVencimento': hojeStr,
            'statusDePagamento': 'EM ABERTO',
            'valorAtualizado': {'valor': '120.00'},
          },
          {
            'numero': 12,
            'dataDeVencimento': futuroStr,
            'statusDePagamento': 'EM ABERTO',
            'valorAtualizado': {'valor': '120.00'},
          },
        ]
      };

      await cubit.buscarDetalhes('101240121849');

      expect(cubit.state, isA<IptuDetalhesSuccess>());
      final success = cubit.state as IptuDetalhesSuccess;

      // Nenhuma parcela em atraso
      expect(success.parcelasVencidas, isEmpty, reason: 'A parcela que vence hoje não deve estar em atraso');

      // Próxima parcela deve ser a 11 (vencendo hoje), e NÃO a 12
      expect(success.proximaParcela, isNotNull);
      expect(success.proximaParcela!.numeroParcela, 11, reason: 'A parcela vencendo hoje deve ser exibida como próximo vencimento');
      expect(success.proximaParcela!.status, ParcelaStatus.emAberto);

      // Parcela 12 deve estar nas parcelas futuras
      expect(success.parcelasFuturas.length, 1);
      expect(success.parcelasFuturas.first.numeroParcela, 12);

      // Histórico de pagas
      expect(success.parcelasPagas.length, 1);
      expect(success.parcelasPagas.first.numeroParcela, 10);
    });

    test('quando existe parcela com vencimento anterior a hoje, deve constar em parcelasVencidas', () async {
      final ontemStr = DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 2)));
      final hojeStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

      fakeRepository.mockDetalhes = {
        'parcelas': [
          {
            'numero': 10,
            'dataDeVencimento': ontemStr,
            'statusDePagamento': 'EM ABERTO',
            'valorAtualizado': {'valor': '120.00'},
          },
          {
            'numero': 11,
            'dataDeVencimento': hojeStr,
            'statusDePagamento': 'EM ABERTO',
            'valorAtualizado': {'valor': '120.00'},
          },
        ]
      };

      await cubit.buscarDetalhes('101240121849');

      expect(cubit.state, isA<IptuDetalhesSuccess>());
      final success = cubit.state as IptuDetalhesSuccess;

      // Parcela 10 está realmente vencida
      expect(success.parcelasVencidas.length, 1);
      expect(success.parcelasVencidas.first.numeroParcela, 10);

      // Próxima parcela aberta é a 11 (hoje)
      expect(success.proximaParcela, isNotNull);
      expect(success.proximaParcela!.numeroParcela, 11);
    });
  });
}
