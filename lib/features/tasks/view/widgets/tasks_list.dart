import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/tasks/domain/task.dart';
import 'package:gistol_dashboard/features/tasks/view/provider.dart';
import 'package:gistol_dashboard/features/tasks/view/widgets/task_details_card.dart';
import 'package:gistol_dashboard/features/tasks/view/widgets/task_tile.dart';
import 'package:provider/provider.dart';

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  String _groupTitle(List<Group> groups, int groupId) {
    for (final group in groups) {
      if (group.id == groupId) return group.title;
    }
    return '#$groupId';
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final groupProvider = context.watch<GroupProvider>();

    return LoaderWrapper(
      loading: tasksProvider.isUpdateLoading,
      child: ValueListenableBuilder<List<SituationTask>>(
        valueListenable: tasksProvider.tasks,
        builder: (context, _, child) {
          final tasks = tasksProvider.visibleTasks;
          if (tasks.isEmpty) {
            return Center(
              child: AppBtn(
                icon: Icons.restore,
                onPressed: () => tasksProvider.fetchTasks(),
              ),
            );
          }

          return ValueListenableBuilder<List<int>>(
            valueListenable: tasksProvider.selectedTasks,
            builder: (context, selectedIds, child) {
              return ValueListenableBuilder<List<Group>>(
                valueListenable: groupProvider.groups,
                builder: (context, groups, child) {
                  return ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskTile(
                        task: task,
                        groupTitle: _groupTitle(groups, task.groupId),
                        isSelected: selectedIds.contains(task.id),
                        onSelect: tasksProvider.toggleTaskSelect,
                        onOpen: (opened) {
                          showAppDialog(
                            context: context,
                            content: TaskDetailsCard(task: opened),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
