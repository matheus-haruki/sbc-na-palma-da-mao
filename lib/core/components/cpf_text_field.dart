import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:palma_da_mao/core/components/app_text_field.dart';
import 'package:palma_da_mao/core/utils/cpf_validator.dart';

class CpfTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;

  const CpfTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.disabled,
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
      initialText: widget.controller.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [_cpfMaskFormatter],
      hintText: '000.000.000-00',
      autovalidateMode: widget.autovalidateMode,
      onChanged: (val) {
        if (widget.onChanged != null) {
          widget.onChanged!(_cpfMaskFormatter.getUnmaskedText());
        }
      },
      validator: widget.validator ??
          (val) {
            final text = val ?? widget.controller.text;
            final unmasked = text.replaceAll(RegExp(r'[^0-9]'), '');
            if (unmasked.isEmpty) {
              return 'Informe o CPF';
            }
            if (unmasked.length < 11 || !CpfValidator.isValid(unmasked)) {
              return 'Digite um CPF válido';
            }
            return null;
          },
    );
  }
}
