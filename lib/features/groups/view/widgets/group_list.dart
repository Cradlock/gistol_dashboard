import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/entry/entry.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/groups/view/provider.dart';
import 'package:gistol_dashboard/features/groups/view/widgets/group_tile.dart';
import 'package:provider/provider.dart';
class GroupList extends StatelessWidget {
  const GroupList({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.read<GroupProvider>();

    return LoaderWrapper(
      loading: groupProvider.isUpdateGroupsLoading, 
      child: ValueListenableBuilder<List<Group>>(
        valueListenable: groupProvider.groups, 
        builder: (context, groups, child) {
          if (groups.isEmpty) {
            return Center(
              child: AppBtn(
                icon: Icons.restore,
                onPressed: () => groupProvider.fetchGroups(),
              ),
            );
          }
          
          return ValueListenableBuilder<List<int>>(
            valueListenable: groupProvider.selectedGroups,
            builder: (context, selectedIds, child) {
                return ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final isSelect = selectedIds.contains(group.id);
                  return GroupTile(
                    title: "${group.title} : ${AppStrings.groups.course.tr()} ${group.year}",
                    id: group.id,
                    createdDate: group.createdDate,
                    isSelected: isSelect,
                    isDeleted: group.isActive != true,
                    onSelect: (int id) {
                      debugPrint("select; $id");
                      groupProvider.toggleGroupSelect(group.id);
                    },
                    // onEditTap опускаем, и карточка сама станет тусклой и без кнопки редактирования
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
