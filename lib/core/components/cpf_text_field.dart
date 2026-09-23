import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/components/app_input_container.dart';

class CpfTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;

  const CpfTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  State<CpfTextField> createState() => _CpfTextFieldState();
}

class _CpfTextFieldState extends State<CpfTextField> {
  late final MaskTextInputFormatter _cpfMaskFormatter;

  @override
  void initState() {
    super.initState();
    _cpfMaskFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppInputContainer(
      child: TextFormField(
        controller: widget.controller,
        inputFormatters: [_cpfMaskFormatter],
        onChanged: (val) {
          if (widget.onChanged != null) {
            widget.onChanged!(_cpfMaskFormatter.getUnmaskedText());
          }
        },
        validator: widget.validator ?? (val) {
          if (val == null || _cpfMaskFormatter.getUnmaskedText().length != 11) {
            return 'Digite um CPF válido com 11 números';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: '000.000.000-00',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
