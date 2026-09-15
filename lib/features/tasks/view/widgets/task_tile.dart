import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/tasks/domain/task.dart';

class TaskTile extends StatelessWidget {
  final SituationTask task;
  final String groupTitle;
  final bool isSelected;
  final ValueChanged<int> onSelect;
  final ValueChanged<SituationTask> onOpen;

  const TaskTile({
    super.key,
    required this.task,
    required this.groupTitle,
    required this.isSelected,
    required this.onSelect,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range =
        '${DateFormat('dd.MM.yyyy HH:mm').format(task.startAt.toLocal())} — ${DateFormat('dd.MM.yyyy HH:mm').format(task.endAt.toLocal())}';

    return Material(
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onOpen(task),
        child: ListTile(
          leading: Checkbox(
            value: isSelected,
            onChanged: (_) => onSelect(task.id),
          ),
          title: Text(task.title, style: theme.textTheme.bodyLarge),
          subtitle: Text(
            '${task.content}\n'
            '$groupTitle • ${task.points} ${AppStrings.tasks.points.tr()}\n$range',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
