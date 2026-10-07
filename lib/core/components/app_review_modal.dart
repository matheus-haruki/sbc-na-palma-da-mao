import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class AppReviewModal extends StatefulWidget {
  final VoidCallback onFinish;

  const AppReviewModal({super.key, required this.onFinish});

  static void show(BuildContext context, {required VoidCallback onFinish}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppReviewModal(onFinish: onFinish),
    );
  }

  @override
  State<AppReviewModal> createState() => _AppReviewModalState();
}

class _AppReviewModalState extends State<AppReviewModal> {
  int _rating = 0;
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_rating == 0) return;
    
    setState(() => _isSubmitting = true);
    
    // Mock save logic: aguarda 1 segundo para simular o backend
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    Navigator.pop(context); // Fecha o modal de avaliação
    widget.onFinish(); // Executa o callback final (voltar para a home)
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      title: Text(
        'Avalie sua experiência',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.darkBlue,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Como foi sua experiência ao registrar essa solicitação hoje?',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 38,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (!_isSubmitting)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onFinish();
            },
            child: const Text('Pular', style: TextStyle(color: Colors.grey)),
          ),
        if (!_isSubmitting)
          ElevatedButton(
            onPressed: _rating > 0 ? _submitReview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Enviar Avaliação',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (_isSubmitting)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
      ],
    );
  }
}
