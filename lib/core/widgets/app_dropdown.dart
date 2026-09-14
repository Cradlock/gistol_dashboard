import 'package:flutter/material.dart';
import 'app_input.dart';

class AppDropdown<T extends Object> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String Function(T item) itemAsString;
  final ValueChanged<T?> onChanged;
  final String? placeholder;
  final String? errorText;

  const AppDropdown({
    super.key,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.value,
    this.placeholder,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemAsString(item),
            style: theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      // Используем стиль твоего AppInput через decoration, чтобы дизайн сохранялся единым
      decoration: InputDecoration(
        hintText: placeholder,
        errorText: errorText,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      dropdownColor: theme.colorScheme.surface,
      isExpanded: true,
    );
  }
}
