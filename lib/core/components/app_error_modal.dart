import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class AppErrorModal extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const AppErrorModal({
    super.key,
    this.title = 'Problemas técnicos!',
    this.message =
        'Não foi possível enviar sua solicitação. Por favor, verifique sua conexão com a internet e tente novamente mais tarde.',
    this.buttonText = 'OK',
    this.onPressed,
  });

  static void show(
    BuildContext context, {
    String title = 'Problemas técnicos!',
    String message =
        'Não foi possível enviar sua solicitação. Por favor, verifique sua conexão com a internet e tente novamente mais tarde.',
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppErrorModal(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: AppColors.surface,
      title: Column(
        children: [
          Image.asset(
            AppAssets.iconeErro,
            width: 75,
            height: 75,
            fit: BoxFit.contain,
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
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 15,
          height: 1.5,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onPressed?.call();
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
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
