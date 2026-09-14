import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:gistol_dashboard/features/students/view/widgets/filter_card.dart';
import 'package:gistol_dashboard/features/students/view/widgets/sort_card.dart';
import 'package:provider/provider.dart';

class StudentsNavbar extends StatelessWidget {
  const StudentsNavbar({super.key});

  Future<void> _requireSelection({
    required BuildContext context,
    required StudentsProvider provider,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    if (provider.selectedStudents.isEmpty) {
      await showActionConfirmDialog(
        context: context,
        message: AppStrings.students.notSelected.tr(),
        isCancel: false,
      );
      return;
    }

    await showActionConfirmDialog(
      context: context,
      message: '$message? (${provider.selectedStudents.length})',
      onConfirm: onConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentsProvider>();
    final students = provider.students;
    final selectedIds = provider.selectedStudents;
    final isAllSelected = students.isNotEmpty &&
        students.every((student) => selectedIds.contains(student.id));
    final showUnconfirm = provider.filterParams.confirmed &&
        !provider.filterParams.deleted;
    final showRestore = provider.filterParams.deleted;

    return Column(
      children: [
        Row(
          children: [
            if (students.isNotEmpty)
              Checkbox(
                value: isAllSelected,
                onChanged: (bool? value) {
                  if (value == true) {
                    provider.setSelectedStudents(
                      students.map((student) => student.id).toList(),
                    );
                  } else {
                    provider.clearSelectedStudents();
                  }
                },
              ),
            const SizedBox(width: 8),
            Expanded(
              child: AppInput(
                prefixIcon: const Icon(Icons.search),
                placeholder: AppStrings.students.fioPlaceholder.tr(),
                onChanged: provider.onFioChanged,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.tune),
              tooltip: AppStrings.students.filters.tr(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              offset: const Offset(0, 40),
              onSelected: (String value) async {
                if (value == 'sort') {
                  await showAppDialog(
                    context: context,
                    content: const StudentSortCard(),
                  );
                }
                if (value == 'filter') {
                  await showAppDialog(
                    context: context,
                    content: const StudentFilterCard(),
                  );
                }
                if (value == 'new') {
                  if (!provider.filterParams.confirmed &&
                      !provider.filterParams.deleted) {
                    await provider.showConfirmedStudents();
                  } else {
                    await provider.showNewStudents();
                  }
                }
                if (value == 'deleted') {
                  if (provider.filterParams.deleted) {
                    await provider.showConfirmedStudents();
                  } else {
                    await provider.showDeletedStudents();
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'sort',
                    child: Row(
                      children: [
                        const Icon(Icons.sort, size: 20),
                        const SizedBox(width: 12),
                        Text(AppStrings.students.sort.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'filter',
                    child: Row(
                      children: [
                        const Icon(Icons.tune, size: 20),
                        const SizedBox(width: 12),
                        Text(AppStrings.students.filters.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'new',
                    child: Row(
                      children: [
                        const Icon(Icons.person_add_alt_1, size: 20),
                        const SizedBox(width: 12),
                        Text(AppStrings.students.newStudents.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'deleted',
                    child: Row(
                      children: [
                        const Icon(Icons.person_off, size: 20),
                        const SizedBox(width: 12),
                        Text(AppStrings.students.deletedStudents.tr()),
                      ],
                    ),
                  ),
                ];
              },
            ),
            const SizedBox(width: 8),
            AppBtn(
              onPressed: () async {
                if (showUnconfirm) {
                  await _requireSelection(
                    context: context,
                    provider: provider,
                    message: AppStrings.students.unconfirmQuestion.tr(),
                    onConfirm: provider.unconfirmStudents,
                  );
                } else {
                  await _requireSelection(
                    context: context,
                    provider: provider,
                    message: AppStrings.students.confirmQuestion.tr(),
                    onConfirm: provider.confirmStudents,
                  );
                }
              },
              icon: showUnconfirm ? Icons.person_remove : Icons.how_to_reg,
              borderRadius: 50,
            ),
            const SizedBox(width: 8),
            AppBtn(
              onPressed: () async {
                if (showRestore) {
                  await _requireSelection(
                    context: context,
                    provider: provider,
                    message: AppStrings.students.recoveryQuestion.tr(),
                    onConfirm: provider.recoveryStudents,
                  );
                } else {
                  await _requireSelection(
                    context: context,
                    provider: provider,
                    message: AppStrings.students.deleteQuestion.tr(),
                    onConfirm: provider.deleteStudents,
                  );
                }
              },
              icon: showRestore ? Icons.restore : Icons.delete,
              borderRadius: 50,
            ),
          ],
        ),
      ],
    );
  }
}
