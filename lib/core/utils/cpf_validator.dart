//TODO: IMPLEMENTAR ESSE CPF_VALIDATOR EM TODOS OS LUGARES DO APP.

class CpfValidator {
  const CpfValidator._();

  /// Valida se um número de CPF é válido de acordo com o cálculo dos dígitos verificadores (módulo 11).
  /// Aceita o CPF com ou sem máscara.
  static bool isValid(String? cpf) {
    if (cpf == null) return false;

    final digits = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11) return false;

    // Rejeita sequências de dígitos repetidos (ex: 00000000000, 11111111111, etc.)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;

    // Cálculo do 1º dígito verificador
    int soma1 = 0;
    for (int i = 0; i < 9; i++) {
      soma1 += int.parse(digits[i]) * (10 - i);
    }
    int resto1 = (soma1 * 10) % 11;
    if (resto1 == 10 || resto1 == 11) resto1 = 0;
    if (resto1 != int.parse(digits[9])) return false;

    // Cálculo do 2º dígito verificador
    int soma2 = 0;
    for (int i = 0; i < 10; i++) {
      soma2 += int.parse(digits[i]) * (11 - i);
    }
    int resto2 = (soma2 * 10) % 11;
    if (resto2 == 10 || resto2 == 11) resto2 = 0;
    if (resto2 != int.parse(digits[10])) return false;

    return true;
  }
}
