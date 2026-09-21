import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:palma_da_mao/modules/iptu/models/guia_pagamento_model.dart';
import 'package:barcode/barcode.dart';

Future<Uint8List> gerarPdfGuiaPagamento(GuiaPagamentoModel guia) async {
  // Chamamos o compute para rodar em outra thread (evitando jank na UI)
  return await compute(_buildPdf, guia);
}

// Função Top-level para o Isolate
Future<Uint8List> _buildPdf(GuiaPagamentoModel guia) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho Oficial
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                color: PdfColors.grey100,
              ),
              child: pw.Column(
                children: [
                  pw.Text('PREFEITURA DE SÃO BERNARDO DO CAMPO', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Documento de Arrecadação Municipal - IPTU', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 32),
            
            // Dados da Guia
            pw.Text('Linha Digitável:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text(
              guia.linhaDigitavel,
              style: pw.TextStyle(fontSize: 14, font: pw.Font.courier()),
            ),
            pw.SizedBox(height: 40),

            // Código de Barras Renderizado Nativamente em Vetor (Padrão ITF Febraban)
            if (guia.linhaDigitavel.isNotEmpty && guia.linhaDigitavel.length > 20)
              pw.Center(
                child: pw.Container(
                  height: 80,
                  width: 400,
                  child: pw.BarcodeWidget(
                    barcode: Barcode.itf(), // Interleaved 2 of 5 (Padrão Febraban)
                    data: guia.linhaDigitavel.replaceAll(RegExp(r'[^0-9]'), ''),
                    drawText: false,
                    color: PdfColors.black,
                  ),
                ),
              )
            else
              pw.Center(child: pw.Text('Código de barras não disponível para esta linha.', style: const pw.TextStyle(color: PdfColors.grey))),
            
            pw.SizedBox(height: 40),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Text('ATENÇÃO: Pague este documento até o vencimento. Após o vencimento, atualize a guia pelo site oficial ou procure a Dívida Ativa.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}
