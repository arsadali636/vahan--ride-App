import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../typography/app_typography.dart';

/// Standard labeled input field. Styling comes entirely from the central
/// `InputDecorationTheme`.
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter> inputFormatters;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters = const [],
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      style: AppTypography.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        errorText: error,
        prefix: prefix,
        suffix: suffix,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength == null ? '' : null,
      ),
    );
  }
}
