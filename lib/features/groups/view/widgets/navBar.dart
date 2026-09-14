

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/domain/group.dart';
import 'package:gistol_dashboard/features/groups/view/provider.dart';
import 'package:gistol_dashboard/features/groups/view/widgets/add_group_card.dart';
import 'package:gistol_dashboard/features/groups/view/widgets/group_filter_card.dart';
import 'package:gistol_dashboard/features/groups/view/widgets/group_sort_card.dart';
import 'package:provider/provider.dart';

class GroupNavbar extends StatelessWidget {
  const GroupNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.read<GroupProvider>();

    return Column(
      children: [
        Row(
          children: [
            ValueListenableBuilder<List<Group>>(
              valueListenable: groupProvider.groups,
              builder: (context, groups, child) {
                if (groups.isEmpty) return const SizedBox.shrink();

                return ValueListenableBuilder<List<int>>(
                  valueListenable: groupProvider.selectedGroups,
                  builder: (context, selectedIds, child) {
                    final bool isAllSelected = groups.isNotEmpty && 
                        groups.every((group) => selectedIds.contains(group.id));

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isAllSelected,
                          onChanged: (bool? value) {
                            if (value == true) {
                              final allIds = groups.map((g) => g.id).toList();
                              groupProvider.setSelectedGroups(allIds);
                            } else {
                              groupProvider.clearSelectedGroups();
                            }
                          },
                        ),
                        // Можешь добавить текст, если нужно, или оставить только чекбокс
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),

            Expanded(  
              child: AppInput(
                prefixIcon: const Icon(Icons.search),
                placeholder: AppStrings.groups.searchPlaceholder.tr(),
                onChanged: groupProvider.onSearchChanged  
              ),
            ),

            const SizedBox(width: 8),  
            PopupMenuButton(
              icon: const Icon(Icons.tune),
              tooltip: AppStrings.groups.filters.tr(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              offset: const Offset(0, 40),
              onSelected: (String value) {
                if(value == "sort"){
                  showAppDialog(context: context, content: GroupSortCard());
                }
                if(value == "filter"){
                  showAppDialog(context: context, content: GroupFilterCard());
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                   value: 'sort', 
                   child: Row(
                     children: [
                       Icon(Icons.sort, size: 20),
                       SizedBox(width: 12),
                       Text(AppStrings.groups.sort.tr()),
                     ],
                   ),
                  ),
                  PopupMenuItem(
                    value: 'filter',
                    child: Row( 
                      children: [
                        Icon(Icons.tune,size: 20),
                        SizedBox(width: 12),
                        Text(AppStrings.groups.filters.tr())
                      ]
                    )
                  )
                ];
              }
            ),
            const SizedBox(width: 8),  
            AppBtn(
              onPressed: () async {
                if(groupProvider.selectedGroups.value.length <= 0){
                  await showActionConfirmDialog(
                    context: context,
                    message: AppStrings.groups.notSelected.tr(),
                    isCancel: false
                  );
                  return; 
                } 
                await showActionConfirmDialog(
                  context: context, 
                  message: "${AppStrings.groups.deleteQuestion.tr()} (${groupProvider.selectedGroups.value.length})", 
                  onConfirm: () async {
                    
                    await groupProvider.deleteSelectedGroups();
                  }
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
                  content: const AddGroupCard(),
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
