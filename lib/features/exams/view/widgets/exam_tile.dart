import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';

class ExamTile extends StatelessWidget {
  const ExamTile({
    super.key,
    required this.exam,
    required this.isSelected,
    required this.onSelect,
    required this.onOpen,
  });

  final ExamSummary exam;
  final bool isSelected;
  final ValueChanged<int> onSelect;
  final ValueChanged<ExamSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = DateFormat('dd.MM.yyyy HH:mm').format(exam.startAt.toLocal());

    return Material(
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onOpen(exam),
        child: ListTile(
          leading: Checkbox(
            value: isSelected,
            onChanged: (_) => onSelect(exam.id),
          ),
          title: Text(exam.title, style: theme.textTheme.bodyLarge),
          subtitle: Text(
            '${exam.theme}\n$start • ${exam.durationMinutes} '
            '${AppStrings.exams.minutes.tr()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
