import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    // No tema dark o ícone fica branco puro; no tema claro mantém a cor
    // original (AppColors.darkBlue), sem alterar o comportamento atual.
    final iconColor = isDark ? Colors.white : AppColors.darkBlue;

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
                  color: AppColors.shadow, // Sombra sutil
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
                  iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. O Texto Externo
          SizedBox(
            width: 90,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String breakAt12(String text) {
  if (text.length <= 12) return text;

  final words = text.split(' ');
  String firstLine = '';

  for (final word in words) {
    final candidate = firstLine.isEmpty ? word : '$firstLine $word';

    if (candidate.length > 12) break;

    firstLine = candidate;
  }

  if (firstLine.isEmpty) {
    return '${text.substring(0, 12)}\n${text.substring(12)}';
  }

  return '$firstLine\n${text.substring(firstLine.length).trim()}';
}