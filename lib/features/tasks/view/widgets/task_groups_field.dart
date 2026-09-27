import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';

Future<List<Group>?> showTaskGroupsPicker({
  required BuildContext context,
  required List<Group> selected,
}) {
  return showAppDialog<List<Group>>(
    context: context,
    content: TaskGroupsDialog(selected: selected),
  );
}

class TaskGroupsField extends StatelessWidget {
  final List<Group> value;
  final ValueChanged<List<Group>> onChanged;
  final String? label;
  final String? placeholder;
  final String? errorText;

  const TaskGroupsField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.errorText,
  });

  Future<void> _open(BuildContext context) async {
    final groups = await showTaskGroupsPicker(
      context: context,
      selected: value,
    );
    if (groups != null) onChanged(groups);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = label ?? placeholder;
    final titles = value.map((group) => group.title).join(', ');

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        isEmpty: value.isEmpty,
        decoration: InputDecoration(
          labelText: caption,
          hintText: value.isEmpty ? placeholder : null,
          errorText: errorText,
          filled: true,
          fillColor: theme.colorScheme.surface,
          prefixIcon: const Icon(Icons.groups_outlined),
          suffixIcon: const Icon(Icons.chevron_right),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ),
        child: Text(
          titles,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class TaskGroupsDialog extends StatefulWidget {
  final List<Group> selected;

  const TaskGroupsDialog({super.key, required this.selected});

  @override
  State<TaskGroupsDialog> createState() => _TaskGroupsDialogState();
}

class _TaskGroupsDialogState extends State<TaskGroupsDialog> {
  late List<Group> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<Group>.from(widget.selected);
  }

  Future<void> _addGroup() async {
    final group = await showGroupPicker(context: context);
    if (group == null) return;
    if (_selected.any((item) => item.id == group.id)) return;
    setState(() => _selected.add(group));
  }

  void _removeGroup(Group group) {
    setState(() => _selected.removeWhere((item) => item.id == group.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 480,
      height: 460,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.tasks.selectedGroups.tr(),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _selected.length + 1,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == _selected.length) {
                  return ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(AppStrings.tasks.addGroup.tr()),
                    onTap: _addGroup,
                  );
                }
                final group = _selected[index];
                return ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: Text(group.title),
                  subtitle: Text(
                    '${AppStrings.groups.course.tr()} ${group.year}',
                  ),
                  trailing: IconButton(
                    tooltip: AppStrings.common.delete.tr(),
                    onPressed: () => _removeGroup(group),
                    icon: const Icon(Icons.close),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: AppBtn(
              text: AppStrings.common.ok.tr(),
              onPressed: () => Navigator.pop(context, List<Group>.from(_selected)),
            ),
          ),
        ],
      ),
    );
  }
}
