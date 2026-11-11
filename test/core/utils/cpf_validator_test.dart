import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/core/utils/cpf_validator.dart';

void main() {
  group('CpfValidator', () {
    test('deve validar CPFs válidos com e sem máscara', () {
      // CPFs válidos conhecidos
      expect(CpfValidator.isValid('08269577146'), isTrue);
      expect(CpfValidator.isValid('082.695.771-46'), isTrue);
      expect(CpfValidator.isValid('52998224725'), isTrue);
      expect(CpfValidator.isValid('529.982.247-25'), isTrue);
    });

    test('deve rejeitar CPFs com tamanho diferente de 11 dígitos', () {
      expect(CpfValidator.isValid(''), isFalse);
      expect(CpfValidator.isValid('123'), isFalse);
      expect(CpfValidator.isValid('1234567890'), isFalse);
      expect(CpfValidator.isValid('123456789012'), isFalse);
      expect(CpfValidator.isValid(null), isFalse);
    });

    test('deve rejeitar sequências de dígitos iguais', () {
      expect(CpfValidator.isValid('00000000000'), isFalse);
      expect(CpfValidator.isValid('11111111111'), isFalse);
      expect(CpfValidator.isValid('22222222222'), isFalse);
      expect(CpfValidator.isValid('33333333333'), isFalse);
      expect(CpfValidator.isValid('44444444444'), isFalse);
      expect(CpfValidator.isValid('55555555555'), isFalse);
      expect(CpfValidator.isValid('66666666666'), isFalse);
      expect(CpfValidator.isValid('77777777777'), isFalse);
      expect(CpfValidator.isValid('88888888888'), isFalse);
      expect(CpfValidator.isValid('99999999999'), isFalse);
    });

    test('deve rejeitar CPFs com dígitos verificadores inválidos', () {
      expect(CpfValidator.isValid('08269577145'), isFalse);
      expect(CpfValidator.isValid('08269577147'), isFalse);
      expect(CpfValidator.isValid('12345678901'), isFalse);
    });
  });
}
