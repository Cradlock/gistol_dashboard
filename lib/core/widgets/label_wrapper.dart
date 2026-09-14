import 'package:flutter/material.dart';

class LabelWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;
  final String? hintText;
  final EdgeInsetsGeometry? padding;

  const LabelWrapper({
    super.key,
    required this.label,
    required this.child,
    this.errorText,
    this.hintText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок (Label)
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          
          // Сам элемент (выпадающий список, инпут и т.д.)
          child,
          
          // Подсказка или текст ошибки снизу (если переданы)
          if (hintText != null && errorText == null) ...[
            const SizedBox(height: 4),
            Text(
              hintText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
