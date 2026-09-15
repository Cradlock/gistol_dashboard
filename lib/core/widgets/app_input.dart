

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInput extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final void Function()? onTap;
  // 1. Добавляем параметр для текста ошибки
  final String? errorText;
  final String? initialValue;

  // Остальные параметры...
  final double? fontSize;
  final Color? borderColor;
  final double borderWidth;
  final double? width;
  final EdgeInsetsGeometry? innerPadding;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? formatters;
  final TextInputType keyboardType;
  const AppInput({
    super.key,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.placeholder,
    this.controller,
    this.formatters,
    this.onChanged,
    this.onTap,
    this.errorText,
    this.fontSize,
    this.borderColor,
    this.borderWidth = 1.0,
    this.width,
    this.innerPadding,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Стили границ (можно автоматически менять цвет рамки на красный, если есть ошибка)
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: errorText != null 
            ? theme.colorScheme.error // Красная рамка при ошибке
            : (borderColor ?? theme.colorScheme.outline.withOpacity(0.5)),
        width: borderWidth,
      ),
    );
    
    Widget inputField = TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: formatters,
      keyboardType: keyboardType,
      obscureText: obscureText,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: fontSize ?? 14.0,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText, // <--- 2. Передаем ошибку в декоратор
        contentPadding: innerPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: borderStyle,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle.copyWith(
          borderSide: BorderSide(
            color: errorText != null ? theme.colorScheme.error : theme.colorScheme.primary,
            width: borderWidth + 0.5,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: inputField,
      );
    }

    return inputField;
  }
}
