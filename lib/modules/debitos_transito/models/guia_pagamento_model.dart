class GuiaPagamentoModel {
  final String linhaDigitavel;
  final String? urlDocumento;
  final String? qrCodePix;

  GuiaPagamentoModel({
    required this.linhaDigitavel,
    this.urlDocumento,
    this.qrCodePix,
  });

  factory GuiaPagamentoModel.fromJson(Map<String, dynamic> json) {
    // Mapeamento defensivo interceptando diversas chaves prováveis de backend legado
    
    String extrairLinhaDigitavel() {
      final keys = ['linhaDigitavel', 'linha_digitavel', 'codigoBarras', 'codigoDeBarras', 'codigoDeBarra', 'linha', 'barCode'];
      for (var key in keys) {
        if (json[key] != null && json[key].toString().trim().isNotEmpty) {
          return json[key].toString().trim();
        }
      }
      return '00000000000.00000000000.00000000000.00000000000'; // Fallback
    }

    return GuiaPagamentoModel(
      linhaDigitavel: extrairLinhaDigitavel(),
      urlDocumento: (json['url'] ?? json['link'] ?? json['urlBoleto'])?.toString(),
      qrCodePix: (json['pix'] ?? json['qrCode'] ?? json['emv'])?.toString(),
    );
  }
}
