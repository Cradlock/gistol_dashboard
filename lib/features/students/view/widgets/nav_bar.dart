import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:gistol_dashboard/features/students/view/students_export.dart';
import 'package:gistol_dashboard/features/students/view/students_export_web.dart';
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

  StudentExportLabels _exportLabels() {
    return StudentExportLabels(
      name: AppStrings.students.editPlaceholderName.tr(),
      surname: AppStrings.students.editPlaceholderSurname.tr(),
      group: AppStrings.students.editPlaceholderGroup.tr(),
      scores: AppStrings.students.editPlaceholderScores.tr(),
      title: AppStrings.students.title.tr(),
    );
  }

  Future<void> _exportSelected({
    required BuildContext context,
    required StudentsProvider provider,
    required void Function(List<StudentExportRow> rows, StudentExportLabels labels)
        action,
  }) async {
    if (provider.selectedStudents.isEmpty) {
      await showActionConfirmDialog(
        context: context,
        message: AppStrings.students.notSelected.tr(),
        isCancel: false,
      );
      return;
    }
    action(studentExportRows(provider.selectedStudentModels), _exportLabels());
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
              tooltip: AppStrings.students.filters.tr(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.tune, size: 20),
                    const SizedBox(width: 8),
                    Text(AppStrings.students.filters.tr()),
                  ],
                ),
              ),
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
            TableOperationsButton(
              operations: [
                TableOperation(
                  icon: Icons.grid_on,
                  title: AppStrings.students.exportExcel.tr(),
                  description: AppStrings.students.exportExcelDesc.tr(),
                  onSelected: () => _exportSelected(
                    context: context,
                    provider: provider,
                    action: (rows, labels) => downloadStudentsExcel(
                      rows: rows,
                      labels: labels,
                    ),
                  ),
                ),
                TableOperation(
                  icon: Icons.print,
                  title: AppStrings.students.printSelected.tr(),
                  description: AppStrings.students.printSelectedDesc.tr(),
                  onSelected: () => _exportSelected(
                    context: context,
                    provider: provider,
                    action: (rows, labels) => printStudentsTable(
                      rows: rows,
                      labels: labels,
                    ),
                  ),
                ),
                TableOperation(
                  icon: showUnconfirm
                      ? Icons.person_remove
                      : Icons.how_to_reg,
                  title: showUnconfirm
                      ? AppStrings.students.unconfirmAction.tr()
                      : AppStrings.students.confirmAction.tr(),
                  description: showUnconfirm
                      ? AppStrings.students.unconfirmDesc.tr()
                      : AppStrings.students.confirmDesc.tr(),
                  onSelected: () => _requireSelection(
                    context: context,
                    provider: provider,
                    message: showUnconfirm
                        ? AppStrings.students.unconfirmQuestion.tr()
                        : AppStrings.students.confirmQuestion.tr(),
                    onConfirm: showUnconfirm
                        ? provider.unconfirmStudents
                        : provider.confirmStudents,
                  ),
                ),
                TableOperation(
                  icon: showRestore ? Icons.restore : Icons.delete,
                  title: showRestore
                      ? AppStrings.students.restoreAction.tr()
                      : AppStrings.students.deleteAction.tr(),
                  description: showRestore
                      ? AppStrings.students.restoreDesc.tr()
                      : AppStrings.students.deleteDesc.tr(),
                  onSelected: () => _requireSelection(
                    context: context,
                    provider: provider,
                    message: showRestore
                        ? AppStrings.students.recoveryQuestion.tr()
                        : AppStrings.students.deleteQuestion.tr(),
                    onConfirm: showRestore
                        ? provider.recoveryStudents
                        : provider.deleteStudents,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
