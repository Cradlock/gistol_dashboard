import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exam_form_dialog.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:provider/provider.dart';

class ExamsNavbar extends StatefulWidget {
  const ExamsNavbar({super.key});

  @override
  State<ExamsNavbar> createState() => _ExamsNavbarState();
}

class _ExamsNavbarState extends State<ExamsNavbar> {
  Group? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamsProvider>();

    return Column(
      children: [
        Row(
          children: [
            ValueListenableBuilder<List<ExamSummary>>(
              valueListenable: provider.exams,
              builder: (context, exams, child) {
                if (exams.isEmpty) return const SizedBox.shrink();
                return ValueListenableBuilder<List<int>>(
                  valueListenable: provider.selectedExams,
                  builder: (context, selectedIds, child) {
                    final isAllSelected =
                        exams.isNotEmpty &&
                        exams.every((exam) => selectedIds.contains(exam.id));
                    return Checkbox(
                      value: isAllSelected,
                      onChanged: (value) {
                        if (value == true) {
                          provider.setSelectedExams(
                            exams.map((exam) => exam.id).toList(),
                          );
                        } else {
                          provider.clearSelectedExams();
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
                placeholder: AppStrings.exams.searchPlaceholder.tr(),
                onChanged: provider.onSearchChanged,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220,
              child: GroupPickerField(
                value: _selectedGroup,
                allowClear: true,
                label: AppStrings.exams.filterGroup.tr(),
                placeholder: AppStrings.exams.filterGroup.tr(),
                onChanged: (group) async {
                  setState(() => _selectedGroup = group);
                  try {
                    await provider.applyGroupFilter(group?.id);
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
                  await provider.applyGroupFilter(null);
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
                if (provider.selectedExams.value.isEmpty) {
                  await showActionConfirmDialog(
                    context: context,
                    message: AppStrings.exams.notSelected.tr(),
                    isCancel: false,
                  );
                  return;
                }
                await showActionConfirmDialog(
                  context: context,
                  message:
                      '${AppStrings.exams.deleteSelected.tr()} (${provider.selectedExams.value.length})',
                  onConfirm: () async {
                    await provider.deleteSelectedExams();
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
                  content: const ExamFormDialog(),
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
