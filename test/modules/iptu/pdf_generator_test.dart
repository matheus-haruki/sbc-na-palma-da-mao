import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/modules/iptu/models/guia_pagamento_model.dart';
import 'package:palma_da_mao/modules/iptu/utils/pdf_generator_isolate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PDF Generator IPTU', () {
    test('Gera PDF com dados mínimos da API (apenas consulta-boleto)', () async {
      final guia = GuiaPagamentoModel(
        linhaDigitavel: '23790.10909 90524.031177 92008.836501 6 16250000177545',
        tipo: 'IMP.PRED. TERRIT.URBANO E TAXAS',
        dataDeVencimento: '09/11/2026',
        valorOriginal: '1.535,52',
        valorAtual: '1.775,45',
        lancamento: '101260121849',
      );

      final pdfBytes = await gerarPdfGuiaPagamento(guia);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('Gera PDF com dados completos (imóvel e encargos)', () async {
      final guia = GuiaPagamentoModel(
        linhaDigitavel: '23790.10909 90524.031177 92008.836501 6 16250000177545',
        tipo: 'IMP.PRED. TERRIT.URBANO E TAXAS',
        dataDeVencimento: '09/11/2026',
        valorOriginal: '1.535,52',
        valorAtual: '1.775,45',
        lancamento: '101260121849',
        inscricaoImobiliaria: '015.094.027.000',
        endereco: 'RUA ALFREDO CALUX 259',
        bairro: 'JARDIM CALUX',
        municipio: 'SAO BERNARDO DO CAMPO',
        uf: 'SP',
        cep: '09895-595',
        codigoDebitoAutomatico: '1.015.094.027.000-56',
        codigoProcessamento: '-10.101.218.492.600.7835',
        parcelasDescricao: 'Todas as parcelas: de 01 à 12',
        atualizacaoMonetaria: '24,56',
        multa: '64,78',
        juros: '75,80',
        honorarios: '74,79',
      );

      final pdfBytes = await gerarPdfGuiaPagamento(guia);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));
    });
    test('Gera PDF para parcela onde API omitiu valorAtual (extrai do código de barras)', () async {
      // Simula retorno da API de parcela sem valorAtual
      final jsonSemValorAtual = {
        'codigoDeBarra': '23790.10909 90524.031177 92008.836501 6 16250000177545',
        'tipo': 'IMP.PRED. TERRIT.URBANO E TAXAS',
        'dataDeVencimento': '09/11/2026',
      };

      final guia = GuiaPagamentoModel.fromJson(jsonSemValorAtual, lancamento: '101260121849');
      // Deve extrair automaticamente da linha digitável: 1.775,45
      expect(guia.valorAtual, isNotNull);
      expect(guia.valorAtual, '1.775,45');

      final pdfBytes = await gerarPdfGuiaPagamento(guia);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));
    });
  });
}
