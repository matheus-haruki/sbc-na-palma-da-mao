import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:palma_da_mao/core/models/guia_pagamento_model.dart';
import 'package:palma_da_mao/core/utils/boleto_utils.dart';
import 'package:barcode/barcode.dart';

class PdfGuiaParam {
  final GuiaPagamentoModel guia;
  final Uint8List? brasaoBytes;

  PdfGuiaParam({required this.guia, this.brasaoBytes});
}

/// Gera a representação em PDF oficial do Documento de Arrecadação Municipal (DAM)
/// da Prefeitura de São Bernardo do Campo (IPTU, Multas de Trânsito, etc.).
///
/// Executado em um Isolate separado via `compute` para manter a UI 100% fluida,
/// ou diretamente caso esteja em ambiente de testes automatizados ou Web.
Future<Uint8List> gerarPdfGuiaPagamento(
  GuiaPagamentoModel guia, {
  Uint8List? brasaoBytes,
  bool useIsolate = true,
}) async {
  Uint8List? imageBytes = brasaoBytes;

  final bool isRunningInTest =
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  if (imageBytes == null && !isRunningInTest) {
    try {
      final ByteData data = await rootBundle
          .load('assets/image/brasao.png')
          .timeout(const Duration(seconds: 1));
      imageBytes = data.buffer.asUint8List();
    } catch (_) {
      try {
        final ByteData data = await rootBundle
            .load('assets/image/brasao.jpg')
            .timeout(const Duration(seconds: 1));
        imageBytes = data.buffer.asUint8List();
      } catch (e) {
        debugPrint('Aviso ao carregar brasão de SBC: $e');
      }
    }
  }

  final param = PdfGuiaParam(guia: guia, brasaoBytes: imageBytes);

  if (!useIsolate || kIsWeb || isRunningInTest) {
    return await _buildPdf(param);
  }

  try {
    return await compute(_buildPdf, param);
  } catch (_) {
    return await _buildPdf(param);
  }
}

// Função Top-level para execução no Isolate
Future<Uint8List> _buildPdf(PdfGuiaParam param) async {
  final guia = param.guia;
  final pdf = pw.Document();

  pw.MemoryImage? brasaoImage;
  if (param.brasaoBytes != null && param.brasaoBytes!.isNotEmpty) {
    try {
      brasaoImage = pw.MemoryImage(param.brasaoBytes!);
    } catch (_) {
      // Ignora e continua gerando sem a imagem caso haja corrupção
    }
  }

  final codigoBarras = BoletoUtils.linhaDigitavelParaCodigoBarras(guia.linhaDigitavel);
  final agora = DateTime.now();
  final dataEmissao = DateFormat('dd/MM/yyyy').format(agora);
  final horaEmissao = DateFormat('HH:mm:ss').format(agora);

  String formatarMoeda(String? valor, [String? fallback]) {
    final v = (valor != null && valor.trim().isNotEmpty && valor.trim() != '-')
        ? valor
        : fallback;
    if (v == null || v.trim().isEmpty || v.trim() == '-') return '-';
    final limpo = v.trim();
    if (limpo.startsWith('R\$')) return limpo;
    return 'R\$ $limpo';
  }

  // Verifica se há dados cadastrais de imóvel vindos do endpoint
  final temInscricao = guia.inscricaoImobiliaria != null && guia.inscricaoImobiliaria!.trim().isNotEmpty;
  final temEndereco = guia.endereco != null && guia.endereco!.trim().isNotEmpty;
  final temBairro = guia.bairro != null && guia.bairro!.trim().isNotEmpty;
  final temCep = guia.cep != null && guia.cep!.trim().isNotEmpty;
  final temDadosImovel = temInscricao || temEndereco || temBairro || temCep;

  // Verifica campos da composição de valores (só exibe os que vierem do endpoint)
  final temMulta = guia.multa != null && guia.multa!.trim().isNotEmpty;
  final temJuros = guia.juros != null && guia.juros!.trim().isNotEmpty;
  final temAtualizacao = guia.atualizacaoMonetaria != null && guia.atualizacaoMonetaria!.trim().isNotEmpty;
  final temHonorarios = guia.honorarios != null && guia.honorarios!.trim().isNotEmpty;
  final temPrincipal = (guia.valorOriginal != null && guia.valorOriginal!.trim().isNotEmpty) ||
      (guia.principal != null && guia.principal!.trim().isNotEmpty);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 30),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // 1. Cabeçalho Institucional Oficial com Brasão no canto superior esquerdo
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (brasaoImage != null) ...[
                  pw.Container(
                    width: 48,
                    height: 56,
                    child: pw.Image(brasaoImage, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 12),
                ],
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'MUNICÍPIO DE SÃO BERNARDO DO CAMPO',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'SECRETARIA DE FINANÇAS',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'DEPARTAMENTO DO TESOURO',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                if (brasaoImage != null)
                  pw.SizedBox(width: 60), // Equilíbrio para manter a centralização exata
              ],
            ),
            pw.SizedBox(height: 14),

            // 2. Faixa Cinza Oficial do Tributo
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                border: pw.Border.all(color: PdfColors.black, width: 0.7),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: pw.Center(
                child: pw.Text(
                  guia.tipo != null && guia.tipo!.trim().isNotEmpty
                      ? 'SEGUNDA VIA SIMPLIFICADA DE ${guia.tipo!.toUpperCase()}'
                      : 'SEGUNDA VIA SIMPLIFICADA DE GUIA DE ARRECADAÇÃO',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
            pw.SizedBox(height: 12),

            // 3. Data e Hora de Emissão
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Data de Emissão: $dataEmissao   Hora: $horaEmissao', style: const pw.TextStyle(fontSize: 8)),
              ],
            ),

            // 4. Dados Cadastrais do Imóvel (apenas se existirem na resposta)
            if (temDadosImovel) ...[
              pw.SizedBox(height: 5),
              if (temInscricao)
                pw.Text('Inscrição Imobiliária: ${guia.inscricaoImobiliaria}',
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
              if (temEndereco) ...[
                pw.SizedBox(height: 3),
                pw.Text('Endereço: ${guia.endereco}',
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
              ],
              if (temBairro || temCep) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  children: [
                    if (temBairro)
                      pw.Text('Bairro: ${guia.bairro}   ',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Município: ${guia.municipio ?? "SAO BERNARDO DO CAMPO"}   ',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('UF: ${guia.uf ?? "SP"}   ',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    if (temCep)
                      pw.Text('CEP: ${guia.cep}',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ],
            pw.SizedBox(height: 16),

            // 5. Tabela Principal (Quadro Oficial)
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.7),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Linha opcional: Débito Automático (só exibe se existir)
                  if (guia.codigoDebitoAutomatico != null && guia.codigoDebitoAutomatico!.trim().isNotEmpty) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.7)),
                      ),
                      child: pw.Text('Cód. Débito Automático: ${guia.codigoDebitoAutomatico}',
                          style: const pw.TextStyle(fontSize: 8.5)),
                    ),
                  ],

                  // Bloco Central: Dados do Lançamento (Esquerda) e Composição de Valores (Direita)
                  pw.Table(
                    border: const pw.TableBorder(
                      verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.7),
                    ),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(5),
                      1: pw.FlexColumnWidth(4),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          // Coluna Esquerda: Lançamento e Bancos
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      'Referente: ${guia.anoReferencia ?? DateFormat('yyyy').format(agora)}',
                                      style: const pw.TextStyle(fontSize: 8.5),
                                    ),
                                    pw.SizedBox(width: 14),
                                    pw.Text(
                                      'Lançamento: ${guia.lancamento ?? "-"}',
                                      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                                    ),
                                  ],
                                ),
                                if (guia.parcelasDescricao != null && guia.parcelasDescricao!.trim().isNotEmpty) ...[
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    guia.parcelasDescricao!,
                                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                                  ),
                                ],
                                pw.SizedBox(height: 18),
                                pw.Text(
                                  'Rede Bancária autorizada a receber até a data de vencimento',
                                  style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  'Banco do Brasil - Santander - Itaú - Caixa Econômica - Bradesco - Mercantil',
                                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey800),
                                ),
                              ],
                            ),
                          ),

                          // Coluna Direita: Valores (só exibe os campos presentes)
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                if (temPrincipal)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 3),
                                    child: pw.Text(
                                      'Principal: ${formatarMoeda(guia.valorOriginal ?? guia.principal)}',
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                                if (temAtualizacao)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 3),
                                    child: pw.Text(
                                      'Atualização Monetária: ${formatarMoeda(guia.atualizacaoMonetaria)}',
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                                if (temMulta)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 3),
                                    child: pw.Text(
                                      'Multa: ${formatarMoeda(guia.multa)}',
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                                if (temJuros)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 3),
                                    child: pw.Text(
                                      'Juros: ${formatarMoeda(guia.juros)}',
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                                if (temHonorarios)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 3),
                                    child: pw.Text(
                                      'Honorários: ${formatarMoeda(guia.honorarios)}',
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Linha inferior do quadro: Processamento, Vencimento e Valor a Pagar
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.7)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: pw.Row(
                      children: [
                        if (guia.codigoProcessamento != null && guia.codigoProcessamento!.trim().isNotEmpty) ...[
                          pw.Expanded(
                            flex: 4,
                            child: pw.Text(
                              'Cód. Processamento:\n${guia.codigoProcessamento}',
                              style: const pw.TextStyle(fontSize: 7.5),
                            ),
                          ),
                        ],
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Vencimento', style: const pw.TextStyle(fontSize: 7.5)),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                guia.dataDeVencimento ?? '-',
                                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Valor Total a Pagar', style: const pw.TextStyle(fontSize: 7.5)),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                formatarMoeda(guia.valorAtual, guia.valorOriginal),
                                style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Faixa de Aviso: Não receber após vencimento
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.7)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Center(
                      child: pw.Text(
                        'BANCO NÃO RECEBER APÓS A DATA DE VENCIMENTO',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 26),

            // 6. Linha de Autenticação Mecânica e Picote
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('VIA CONTRIBUINTE', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text('AUTENTICAÇÃO MECÂNICA', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8, color: PdfColors.grey700),
            pw.SizedBox(height: 22),

            // 7. Ficha de Compensação (Canhoto Inferior)
            // Linha Digitável
            pw.Center(
              child: pw.Text(
                guia.linhaDigitavel,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.courier(),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            pw.SizedBox(height: 12),

            // Código de Barras ITF Febraban (44 dígitos)
            if (codigoBarras != null && codigoBarras.length == 44)
              pw.Center(
                child: pw.Container(
                  height: 60,
                  width: 400,
                  child: pw.BarcodeWidget(
                    barcode: Barcode.itf(),
                    data: codigoBarras,
                    drawText: false,
                    color: PdfColors.black,
                  ),
                ),
              )
            else
              pw.Center(
                child: pw.Text(
                  'Código de barras não disponível para esta linha.',
                  style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8),
                ),
              ),
            pw.SizedBox(height: 14),

            // Mini Faixa Cinza Inferior
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                border: pw.Border.all(color: PdfColors.black, width: 0.7),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: pw.Center(
                child: pw.Text(
                  guia.tipo != null && guia.tipo!.trim().isNotEmpty
                      ? 'MUNICÍPIO DE SÃO BERNARDO DO CAMPO - ${guia.tipo!.toUpperCase()}'
                      : 'MUNICÍPIO DE SÃO BERNARDO DO CAMPO - DOCUMENTO DE ARRECADAÇÃO',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),

            // Mini Tabela Resumo da Ficha de Compensação
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.7),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Lançamento: ${guia.lancamento ?? "-"}',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Vencimento: ${guia.dataDeVencimento ?? "-"}',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  if (temPrincipal)
                    pw.Text('Principal: ${formatarMoeda(guia.valorOriginal ?? guia.principal)}',
                        style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('Valor a Pagar: ${formatarMoeda(guia.valorAtual, guia.valorOriginal)}',
                      style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // 8. Rodapé com Link Clicável Oficial da Prefeitura de SBC
            pw.Center(
              child: pw.UrlLink(
                destination: 'https://www.saobernardo.sp.gov.br/web/sbc/parcelamento-no-cartao',
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Clique aqui se deseja parcelar por cartão de crédito',
                      style: pw.TextStyle(
                        color: PdfColors.blue800,
                        fontSize: 8.5,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Ou acesse: https://www.saobernardo.sp.gov.br/web/sbc/parcelamento-no-cartao',
                      style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 7.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}
