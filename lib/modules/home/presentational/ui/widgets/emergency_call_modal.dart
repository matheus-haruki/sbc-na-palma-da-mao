import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palma_da_mao/core/constants/emergency_numbers.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/services/phone_service.dart';

class _EmergencyOption {
  final String label;
  final String number;

  const _EmergencyOption(this.label, this.number);
}

class EmergencyCallModal extends StatelessWidget {
  const EmergencyCallModal({super.key});

  static const List<_EmergencyOption> _options = [
    _EmergencyOption(
      'Defesa Civil',
      EmergencyNumbers.defesaCivil,
    ),
    _EmergencyOption(
      'Polícia',
      EmergencyNumbers.policia,
    ),
    _EmergencyOption(
      'SAMU',
      EmergencyNumbers.samu,
    ),
    _EmergencyOption(
      'Bombeiros',
      EmergencyNumbers.bombeiros,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra indicadora de arraste
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Ligar para emergência',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toque em um contato para ligar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              ..._options.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCard(context, option),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _EmergencyOption option) {
    final theme = Theme.of(context);
    const Color numberColor = Color(0xFFDC3545);
    const Color borderColor = Color(0xFFFFCDD2);

    return Semantics(
      button: true,
      label:
          'Ligar para ${option.label}, ${option.number}. Pressione e segure para copiar.',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              await PhoneService.call(option.number);
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: option.number));
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Número copiado: ${option.number}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.number,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: numberColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showEmergencyCallModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const EmergencyCallModal(),
  );
}
