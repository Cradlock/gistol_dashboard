import 'package:flutter/material.dart';
import 'app_input.dart'; // Убедись, что путь к твоему AppInput верный

class AppDropdownInput<T extends Object> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) itemAsString;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? placeholder;
  final String? errorText;

  const AppDropdownInput({
    super.key,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Autocomplete<T>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return items;
        }
        return items.where((item) {
          return itemAsString(
            item,
          ).toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: itemAsString,
      onSelected: (T selection) {
        onChanged(selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Используем твой фирменный AppInput
        return AppInput(
          controller: controller,
          focusNode: focusNode,
          label: label,
          placeholder: placeholder,
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(itemAsString(option)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
