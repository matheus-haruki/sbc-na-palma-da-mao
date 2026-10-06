import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palma_da_mao/core/components/app_input_container.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final bool alignLabelWithHint;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppInputContainer(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          alignLabelWithHint: alignLabelWithHint,
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
      ),
    );
  }
}
