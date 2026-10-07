import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSuccessModal extends StatelessWidget {
  final String title;
  final String message;
  final String? highlightedText;
  final String? bottomMessage;
  final String buttonText;
  final VoidCallback onPressed;

  const AppSuccessModal({
    super.key,
    this.title = 'Solicitação Enviada!',
    required this.message,
    this.highlightedText,
    this.bottomMessage,
    this.buttonText = 'OK',
    required this.onPressed,
  });

  static void show(
    BuildContext context, {
    String title = 'Solicitação Enviada!',
    required String message,
    String? highlightedText,
    String? bottomMessage,
    String buttonText = 'OK',
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppSuccessModal(
        title: title,
        message: message,
        highlightedText: highlightedText,
        bottomMessage: bottomMessage,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: AppColors.surface,
      title: Column(
        children: [
          Image.asset(
            AppAssets.iconeSucesso,
            width: 75,
            height: 75,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (highlightedText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    highlightedText!,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textLabel,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: highlightedText!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Protocolo copiado para a área de transferência!'),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(Icons.copy, color: AppColors.darkBlue, size: 22),
                  ),
                ],
              ),
            ),
          ],
          if (bottomMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              bottomMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Remove o modal da tela
            onPressed(); // Executa a ação (ex: abrir o review modal)
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text(
            buttonText,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
