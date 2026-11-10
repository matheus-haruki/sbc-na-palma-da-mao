import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/core/utils/boleto_utils.dart';
import 'package:barcode/barcode.dart';

void main() {
  group('BoletoUtils', () {
    test('converte linha digitável de 47 dígitos (boleto bancário) para 44 dígitos e valida no Barcode.itf', () {
      // Exemplo do IPTU SBC
      const linha = '23790.10909 90524.031177 92008.836501 6 16250000177545';
      final barcode = BoletoUtils.linhaDigitavelParaCodigoBarras(linha);

      expect(barcode, isNotNull);
      expect(barcode!.length, 44);
      expect(barcode, '23796162500001775450109090524031179200883650');

      // Verifica se o Barcode.itf() aceita os 44 dígitos sem lançar BarcodeException
      expect(() => Barcode.itf().verify(barcode), returnsNormally);
    });

    test('mantém código de barras que já possui 44 dígitos numéricos', () {
      const barcodeOriginal = '23796162500001775450109090524031179200883650';
      final barcode = BoletoUtils.linhaDigitavelParaCodigoBarras(barcodeOriginal);

      expect(barcode, equals(barcodeOriginal));
      expect(barcode?.length, 44);
      expect(() => Barcode.itf().verify(barcode!), returnsNormally);
    });

    test('converte linha digitável de 48 dígitos (arrecadação) para 44 dígitos', () {
      // 4 blocos de 12 dígitos -> 48 dígitos
      const linha48 = '816100000011 250024472023 204018247065 999999999991';
      final barcode = BoletoUtils.linhaDigitavelParaCodigoBarras(linha48);

      expect(barcode, isNotNull);
      expect(barcode!.length, 44);
      // Remove o último dígito de cada bloco de 12
      expect(barcode, '81610000001250024472022040182470699999999999');
      expect(() => Barcode.itf().verify(barcode), returnsNormally);
    });

    test('retorna null para formatos inválidos ou nulos', () {
      expect(BoletoUtils.linhaDigitavelParaCodigoBarras(null), isNull);
      expect(BoletoUtils.linhaDigitavelParaCodigoBarras(''), isNull);
      expect(BoletoUtils.linhaDigitavelParaCodigoBarras('12345'), isNull);
    });
  });
}
