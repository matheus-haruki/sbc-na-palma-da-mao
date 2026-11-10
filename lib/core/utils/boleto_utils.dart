class BoletoUtils {
  /// Converte uma Linha Digitável (47 dígitos de boleto bancário ou 48 dígitos de arrecadação)
  /// para o Código de Barras FEBRABAN padrão de 44 dígitos (utilizado pelo ITF / Interleaved 2 of 5).
  ///
  /// Retorna a string com exatamente 44 dígitos numéricos, ou `null` caso a linha não seja válida/conversível.
  static String? linhaDigitavelParaCodigoBarras(String? linhaDigitavel) {
    if (linhaDigitavel == null) return null;

    final numeros = linhaDigitavel.replaceAll(RegExp(r'[^0-9]'), '');

    // Se já tiver 44 dígitos, já é o próprio código de barras FEBRABAN
    if (numeros.length == 44) {
      return numeros;
    }

    // Boleto Bancário de Cobrança - Linha digitável com 47 dígitos
    // Composição da linha digitável:
    // Campo 1 (10): AAABC.CCCCX -> AAA = Banco, B = Moeda, CCCCC = Campo Livre posições 20-24, X = DV
    // Campo 2 (11): DDDDD.DDDDDY -> DDDDDDDDDD = Campo Livre posições 25-34, Y = DV
    // Campo 3 (11): EEEEE.EEEEEZ -> EEEEEEEEEE = Campo Livre posições 35-44, Z = DV
    // Campo 4 (1) : K -> DV Geral do código de barras
    // Campo 5 (14): UUUUVVVVVVVVVV -> UUUU = Fator Vencimento (4), VVVVVVVVVV = Valor Nominal (10)
    //
    // Formato do Código de Barras FEBRABAN (44 dígitos):
    // Posições 01-03: Banco (3)
    // Posição 04-04: Moeda (1)
    // Posição 05-05: DV Geral (1)
    // Posições 06-09: Fator de Vencimento (4)
    // Posições 10-19: Valor Nominal (10)
    // Posições 20-24: Campo Livre bloco 1 (5)
    // Posições 25-34: Campo Livre bloco 2 (10)
    // Posições 35-44: Campo Livre bloco 3 (10)
    if (numeros.length == 47) {
      final banco = numeros.substring(0, 3);
      final moeda = numeros.substring(3, 4);
      final campoLivre1 = numeros.substring(4, 9);
      // indice 9: DV do campo 1 (ignorado)
      final campoLivre2 = numeros.substring(10, 20);
      // indice 20: DV do campo 2 (ignorado)
      final campoLivre3 = numeros.substring(21, 31);
      // indice 31: DV do campo 3 (ignorado)
      final dvGeral = numeros.substring(32, 33);
      final fatorEValor = numeros.substring(33, 47);

      return '$banco$moeda$dvGeral$fatorEValor$campoLivre1$campoLivre2$campoLivre3';
    }

    // Guia de Arrecadação / Concessionária / Tributos - Linha digitável com 48 dígitos
    // Formato: 4 blocos de 12 dígitos, cada um composto por 11 dígitos + 1 DV.
    // O código de barras de 44 dígitos é obtido descartando o 12º dígito (DV) de cada bloco.
    if (numeros.length == 48) {
      final bloco1 = numeros.substring(0, 11);
      // indice 11: DV do bloco 1 (ignorado)
      final bloco2 = numeros.substring(12, 23);
      // indice 23: DV do bloco 2 (ignorado)
      final bloco3 = numeros.substring(24, 35);
      // indice 35: DV do bloco 3 (ignorado)
      final bloco4 = numeros.substring(36, 47);
      // indice 47: DV do bloco 4 (ignorado)

      return '$bloco1$bloco2$bloco3$bloco4';
    }

    return null;
  }
}
