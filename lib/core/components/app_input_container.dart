import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class AppInputContainer extends StatelessWidget {
  final Widget child;
  final bool hasError;

  const AppInputContainer({
    super.key,
    required this.child,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError
              ? Colors.red.shade600
              : theme.colorScheme.outlineVariant,
          width: hasError ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? Colors.red.withValues(alpha: 0.08)
                : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
