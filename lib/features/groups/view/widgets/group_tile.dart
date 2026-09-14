import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';

class GroupTile extends StatelessWidget {
  final String title;
  final int id;
  final DateTime createdDate;
  final bool isSelected;
  final ValueChanged<int> onSelect;
  final ValueChanged<int>? onEditTap; // Делаем опциональным для удаленных
  final bool isDeleted;

  const GroupTile({
    super.key,
    required this.isDeleted,
    required this.title,
    required this.id,
    required this.createdDate,
    required this.isSelected,
    required this.onSelect,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(createdDate);
    

    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: Material(
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: () => onSelect(id),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: ListTile(
              leading: Checkbox(
                value: isSelected,
                onChanged: (_) => onSelect(id),
              ),
              title: Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                '${AppStrings.groups.created.tr()}: $formattedDate',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              // Если это удаленная группа, trailing будет null (кнопки нет)
              trailing: isDeleted
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => onEditTap!(id),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
