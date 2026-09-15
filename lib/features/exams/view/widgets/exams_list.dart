import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exam_details_dialog.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exam_tile.dart';
import 'package:provider/provider.dart';

class ExamsList extends StatelessWidget {
  const ExamsList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamsProvider>();

    return LoaderWrapper(
      loading: provider.isUpdating,
      child: ValueListenableBuilder<List<ExamSummary>>(
        valueListenable: provider.exams,
        builder: (context, exams, child) {
          if (exams.isEmpty) {
            return Center(
              child: AppBtn(
                icon: Icons.restore,
                onPressed: () => provider.fetchExams(),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<int>>(
                  valueListenable: provider.selectedExams,
                  builder: (context, selectedIds, child) {
                    return ListView.separated(
                      itemCount: exams.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final exam = exams[index];
                        return ExamTile(
                          exam: exam,
                          isSelected: selectedIds.contains(exam.id),
                          onSelect: provider.toggleExamSelect,
                          onOpen: (opened) {
                            showAppDialog(
                              context: context,
                              content: ExamDetailsDialog(examId: opened.id),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: provider.hasPrevious
                        ? provider.previousPage
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${provider.page} • ${provider.total} '
                    '${AppStrings.exams.total.tr()}',
                  ),
                  IconButton(
                    onPressed: provider.hasNext ? provider.nextPage : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
