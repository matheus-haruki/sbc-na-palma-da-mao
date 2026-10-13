import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class ServicoMaisUtilizadoCard extends StatelessWidget {
  final String titulo;
  final String iconePath;
  final VoidCallback onTap;

  const ServicoMaisUtilizadoCard({
    super.key,
    required this.titulo,
    required this.iconePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundBlue,
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconePath,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.darkBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    titulo,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
