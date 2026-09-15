import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/tasks/domain/task.dart';
import 'package:gistol_dashboard/features/tasks/view/provider.dart';
import 'package:gistol_dashboard/features/tasks/view/widgets/add_task_card.dart';
import 'package:provider/provider.dart';

class TasksNavbar extends StatefulWidget {
  const TasksNavbar({super.key});

  @override
  State<TasksNavbar> createState() => _TasksNavbarState();
}

class _TasksNavbarState extends State<TasksNavbar> {
  Group? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();

    return Column(
      children: [
        Row(
          children: [
            ValueListenableBuilder<List<SituationTask>>(
              valueListenable: tasksProvider.tasks,
              builder: (context, tasks, child) {
                if (tasks.isEmpty) return const SizedBox.shrink();
                return ValueListenableBuilder<List<int>>(
                  valueListenable: tasksProvider.selectedTasks,
                  builder: (context, selectedIds, child) {
                    final isAllSelected = tasks.isNotEmpty &&
                        tasks.every((task) => selectedIds.contains(task.id));
                    return Checkbox(
                      value: isAllSelected,
                      onChanged: (value) {
                        if (value == true) {
                          tasksProvider.setSelectedTasks(
                            tasks.map((task) => task.id).toList(),
                          );
                        } else {
                          tasksProvider.clearSelectedTasks();
                        }
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppInput(
                prefixIcon: const Icon(Icons.search),
                placeholder: AppStrings.tasks.searchPlaceholder.tr(),
                onChanged: tasksProvider.onSearchChanged,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220,
              child: GroupPickerField(
                value: _selectedGroup,
                allowClear: true,
                placeholder: AppStrings.tasks.filterGroup.tr(),
                onChanged: (group) async {
                  setState(() => _selectedGroup = group);
                  try {
                    await tasksProvider.applyGroupFilter(group?.id);
                  } on AppException catch (e) {
                    ErrorHandler.handle(e);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            AppBtn(
              onPressed: () async {
                try {
                  await tasksProvider.applyGroupFilter(null);
                  if (mounted) setState(() => _selectedGroup = null);
                } on AppException catch (e) {
                  ErrorHandler.handle(e);
                }
              },
              icon: Icons.filter_alt_off,
              borderRadius: 50,
            ),
            const SizedBox(width: 8),
            AppBtn(
              onPressed: () async {
                if (tasksProvider.selectedTasks.value.isEmpty) {
                  await showActionConfirmDialog(
                    context: context,
                    message: AppStrings.tasks.notSelected.tr(),
                    isCancel: false,
                  );
                  return;
                }
                await showActionConfirmDialog(
                  context: context,
                  message:
                      '${AppStrings.tasks.deleteQuestion.tr()} (${tasksProvider.selectedTasks.value.length})',
                  onConfirm: () async {
                    await tasksProvider.deleteSelectedTasks();
                  },
                );
              },
              icon: Icons.delete,
              borderRadius: 50,
            ),
            const SizedBox(width: 8),
            AppBtn(
              onPressed: () async {
                await showAppDialog(
                  context: context,
                  content: const AddTaskCard(),
                );
              },
              icon: Icons.add,
              borderRadius: 50,
            ),
          ],
        ),
      ],
    );
  }
}
