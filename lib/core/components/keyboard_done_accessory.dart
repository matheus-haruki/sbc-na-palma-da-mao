import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class KeyboardDoneAccessory extends StatelessWidget {
  final Widget child;
  final List<FocusNode> focusNodes;
  final VoidCallback? onDone;

  const KeyboardDoneAccessory({
    super.key,
    required this.child,
    required this.focusNodes,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        AnimatedBuilder(
          animation: Listenable.merge(focusNodes),
          builder: (context, _) {
            final isAnyFocused = focusNodes.any((node) => node.hasFocus);
            final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

            if (!isAnyFocused || !isKeyboardOpen) {
              return const SizedBox.shrink();
            }

            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        foregroundColor: AppColors.secondary,
                      ),
                      onPressed: () {
                        if (onDone != null) {
                          onDone!();
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: const Text(
                        'Concluído',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
