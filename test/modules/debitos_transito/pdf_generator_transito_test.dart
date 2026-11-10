import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/core/models/guia_pagamento_model.dart';
import 'package:palma_da_mao/core/utils/pdf_guia_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PDF Generator - Débitos de Trânsito', () {
    test('Gera PDF oficial para débitos de trânsito com os valores respectivos', () async {
      final guia = GuiaPagamentoModel(
        linhaDigitavel: '23790.10909 90524.031177 92008.836501 6 16250000177545',
        tipo: 'MULTAS DE TRANSITO',
        dataDeVencimento: '15/12/2026',
        valorOriginal: '293,47',
        valorAtual: '293,47',
        lancamento: '9988776655',
        parcelasDescricao: 'Auto de Infração: A12345678',
      );

      final pdfBytes = await gerarPdfGuiaPagamento(guia);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));
    });
  });
}
