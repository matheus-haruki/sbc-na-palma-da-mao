import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SquareButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const SquareButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. A Caixa Branca (Card do Ícone)
          Container(
            width: 72, // Tamanho ajustado para caber bem em listas horizontais
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary, // Ícone pintado com a cor primária
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. O Texto Externo
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
