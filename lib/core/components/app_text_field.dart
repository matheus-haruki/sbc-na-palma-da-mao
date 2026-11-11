import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palma_da_mao/core/components/app_input_container.dart';

class AppTextField extends FormField<String> {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final bool alignLabelWithHint;
  final bool readOnly;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? customErrorText;

  AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    super.validator,
    super.enabled = true,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.alignLabelWithHint = false,
    this.readOnly = false,
    this.focusNode,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.customErrorText,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          initialValue: controller != null ? controller.text : '',
          builder: (FormFieldState<String> field) {
            final _AppTextFieldState state = field as _AppTextFieldState;
            final theme = Theme.of(field.context);
            final effectiveErrorText = customErrorText ?? field.errorText;
            final hasError = (customErrorText != null &&
                    customErrorText.trim().isNotEmpty) ||
                field.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInputContainer(
                  hasError: hasError,
                  child: TextField(
                    controller: state._effectiveController,
                    readOnly: readOnly,
                    enabled: enabled,
                    focusNode: focusNode,
                    onTap: onTap,
                    onChanged: (val) {
                      state._handleControllerChanged();
                      onChanged?.call(val);
                    },
                    keyboardType: keyboardType,
                    textInputAction: textInputAction ?? TextInputAction.done,
                    onSubmitted: onSubmitted ??
                        (_) => FocusScope.of(field.context).unfocus(),
                    inputFormatters: inputFormatters,
                    minLines: minLines,
                    maxLines: maxLines,
                    maxLength: maxLength,
                    textCapitalization: textCapitalization,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      alignLabelWithHint: alignLabelWithHint,
                      prefixIcon: prefixIcon,
                      suffixIcon: suffixIcon,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorStyle: const TextStyle(fontSize: 0, height: 0),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (hasError && effectiveErrorText != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 6.0),
                    child: Text(
                      effectiveErrorText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            );
          },
        );

  @override
  FormFieldState<String> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  AppTextField get widget => super.widget as AppTextField;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller =
            TextEditingController.fromValue(oldWidget.controller!.value);
      }
      if (widget.controller != null) {
        setValue(widget.controller!.text);
        if (oldWidget.controller == null) {
          _controller?.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.text = widget.initialValue ?? '';
    });
  }

  @override
  bool validate() {
    if (_effectiveController.text != value) {
      setValue(_effectiveController.text);
    }
    return super.validate();
  }

  void _handleControllerChanged() {
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
      if (hasError) {
        validate();
      }
    }
  }
}
