import 'package:flutter/material.dart';

class StudentTile extends StatelessWidget {
  final int id;
  final String name;
  final String year;
  final String group;
  final bool isSelected;
  final bool isDeleted;
  final bool isConfirmed;
  final ValueChanged<int> onSelect;
  final ValueChanged<int>? onEditTap;

  const StudentTile({
    super.key,
    required this.id,
    required this.name,
    required this.year,
    required this.group,
    required this.isSelected,
    required this.isDeleted,
    required this.isConfirmed,
    required this.onSelect,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = !isConfirmed
        ? theme.colorScheme.outline
        : theme.colorScheme.onSurface;
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: color,
      decoration: isDeleted ? TextDecoration.lineThrough : null,
    );

    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: Material(
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: () => onSelect(id),
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (_) => onSelect(id),
            ),
            title: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    name,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('|', style: textStyle),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    year,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('|', style: textStyle),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    group,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: isDeleted
                ? null
                : IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEditTap == null ? null : () => onEditTap!(id),
                  ),
          ),
        ),
      ),
    );
  }
}
