import 'package:intl/intl.dart';

class GuiaPagamentoModel {
  final String linhaDigitavel;
  final String? urlDocumento;
  final String? qrCodePix;

  // Informações tributárias da guia
  final String? tipo;
  final String? lancamento;
  final String? dataDeVencimento;
  final String? valorOriginal;
  final String? valorAtual;
  final String? parcelasDescricao;
  final String? anoReferencia;

  // Dados cadastrais (se fornecidos pelo backend)
  final String? inscricaoImobiliaria;
  final String? endereco;
  final String? bairro;
  final String? municipio;
  final String? uf;
  final String? cep;
  final String? codigoDebitoAutomatico;
  final String? codigoProcessamento;

  // Composição detalhada de valores (se fornecidos pelo backend)
  final String? principal;
  final String? atualizacaoMonetaria;
  final String? multa;
  final String? juros;
  final String? honorarios;

  GuiaPagamentoModel({
    required this.linhaDigitavel,
    this.urlDocumento,
    this.qrCodePix,
    this.tipo,
    this.lancamento,
    this.dataDeVencimento,
    this.valorOriginal,
    this.valorAtual,
    this.parcelasDescricao,
    this.anoReferencia,
    this.inscricaoImobiliaria,
    this.endereco,
    this.bairro,
    this.municipio,
    this.uf,
    this.cep,
    this.codigoDebitoAutomatico,
    this.codigoProcessamento,
    this.principal,
    this.atualizacaoMonetaria,
    this.multa,
    this.juros,
    this.honorarios,
  });

  factory GuiaPagamentoModel.fromJson(
    Map<String, dynamic> json, {
    String? lancamento,
    String? parcelasDescricao,
    Map<String, dynamic>? dadosComplementares,
    String? valorEstimado,
  }) {
    String extrairLinhaDigitavel() {
      final keys = ['linhaDigitavel', 'linha_digitavel', 'codigoBarras', 'codigoDeBarras', 'codigoDeBarra', 'linha', 'barCode'];
      for (var key in keys) {
        if (json[key] != null && json[key].toString().trim().isNotEmpty) {
          return json[key].toString().trim();
        }
      }
      return '00000000000.00000000000.00000000000.00000000000'; // Fallback
    }

    String? buscarCampo(List<String> keys) {
      for (var key in keys) {
        final val = json[key];
        if (val != null) {
          if (val is Map && val['valor'] != null) {
            final v = val['valor'].toString().trim();
            if (v.isNotEmpty) return v;
          }
          final str = val.toString().trim();
          if (str.isNotEmpty) return str;
        }
      }
      if (dadosComplementares != null) {
        for (var key in keys) {
          final val = dadosComplementares[key];
          if (val != null) {
            if (val is Map && val['valor'] != null) {
              final v = val['valor'].toString().trim();
              if (v.isNotEmpty) return v;
            }
            final str = val.toString().trim();
            if (str.isNotEmpty) return str;
          }
        }
      }
      return null;
    }

    String? extrairValor(List<String> keys) {
      final encontrado = buscarCampo(keys);
      if (encontrado != null && encontrado != '0' && encontrado != '0,00' && encontrado != '0.0') {
        return encontrado;
      }
      // Verifica objeto aninhado valorAtualizado
      if (json['valorAtualizado'] != null) {
        final va = json['valorAtualizado'];
        if (va is Map && va['valor'] != null) {
          final v = va['valor'].toString().trim();
          if (v.isNotEmpty && v != '0') return v;
        } else if (va is num || va is String) {
          final v = va.toString().trim();
          if (v.isNotEmpty && v != '0') return v;
        }
      }
      return null;
    }

    // Extração do valor diretamente da linha digitável (FEBRABAN Campo 5)
    String? extrairValorDaLinha(String linha) {
      final digits = linha.replaceAll(RegExp(r'[^0-9]'), '');
      // Boleto Bancário (47 dígitos): os últimos 10 dígitos (índices 37 a 46) são o valor em centavos
      if (digits.length == 47) {
        final centsStr = digits.substring(37, 47);
        final cents = int.tryParse(centsStr) ?? 0;
        if (cents > 0) {
          final valor = cents / 100.0;
          return NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valor).trim();
        }
      }
      // Boleto de Arrecadação (48 dígitos)
      if (digits.length == 48 && digits.startsWith('8')) {
        final centsStr = digits.substring(4, 11) + digits.substring(12, 15);
        final cents = int.tryParse(centsStr) ?? 0;
        if (cents > 0) {
          final valor = cents / 100.0;
          return NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valor).trim();
        }
      }
      return null;
    }

    final linha = extrairLinhaDigitavel();

    var vAtual = extrairValor([
      'valorAtual',
      'valorTotal',
      'total',
      'valorCobrado',
      'valorBoleto',
      'vlrTotal',
      'vlrAtual',
      'valorGuia',
    ]);

    var vOriginal = extrairValor([
      'valorOriginal',
      'principal',
      'valor',
      'valorParcela',
      'valorNominal',
      'vlrOriginal',
    ]);

    // Unifica caso apenas um tenha vindo
    vAtual ??= vOriginal;
    vOriginal ??= vAtual;

    // Se ainda nulo, usa o valor estimado passado pela interface da parcela
    if (vAtual == null && valorEstimado != null && valorEstimado.trim().isNotEmpty) {
      vAtual = valorEstimado.trim();
      vOriginal ??= vAtual;
    }

    // Se ainda nulo, extrai dos dígitos do código de barras/linha digitável
    if (vAtual == null) {
      final vBarcode = extrairValorDaLinha(linha);
      if (vBarcode != null) {
        vAtual = vBarcode;
        vOriginal ??= vAtual;
      }
    }

    return GuiaPagamentoModel(
      linhaDigitavel: linha,
      urlDocumento: (json['url'] ?? json['link'] ?? json['urlBoleto'])?.toString(),
      qrCodePix: (json['pix'] ?? json['qrCode'] ?? json['emv'])?.toString(),
      tipo: buscarCampo(['tipo', 'descricao', 'tributo']),
      lancamento: lancamento ?? buscarCampo(['lancamento', 'numeroLancamento']),
      dataDeVencimento: buscarCampo(['dataDeVencimento', 'vencimento', 'dtVencimento']),
      valorOriginal: vOriginal,
      valorAtual: vAtual,
      parcelasDescricao: parcelasDescricao ?? buscarCampo(['parcelasDescricao', 'parcelas', 'descricaoParcelas']),
      anoReferencia: buscarCampo(['anoReferencia', 'ano', 'exercicio']),
      inscricaoImobiliaria: buscarCampo(['inscricaoImobiliaria', 'inscricao', 'inscricaoCadastral', 'codigoImovel']),
      endereco: buscarCampo(['endereco', 'logradouro', 'rua']),
      bairro: buscarCampo(['bairro']),
      municipio: buscarCampo(['municipio', 'cidade']),
      uf: buscarCampo(['uf', 'estado']),
      cep: buscarCampo(['cep']),
      codigoDebitoAutomatico: buscarCampo(['codigoDebitoAutomatico', 'debitoAutomatico', 'codDebitoAutomatico']),
      codigoProcessamento: buscarCampo(['codigoProcessamento', 'codProcessamento']),
      principal: buscarCampo(['principal', 'valorPrincipal']) ?? vOriginal,
      atualizacaoMonetaria: buscarCampo(['atualizacaoMonetaria', 'atualizacao']),
      multa: buscarCampo(['multa']),
      juros: buscarCampo(['juros']),
      honorarios: buscarCampo(['honorarios']),
    );
  }
}
