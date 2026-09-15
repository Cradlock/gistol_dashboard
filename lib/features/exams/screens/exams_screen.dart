import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exam_details_dialog.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exam_form_dialog.dart';
import 'package:provider/provider.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ExamsProvider>();
      try {
        await provider.initData();
      } on AppException catch (error) {
        if (mounted) ErrorHandler.handle(error, context: context);
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(ExamSummary exam) async {
    final confirmed = await showActionConfirmDialog(
      context: context,
      message: AppStrings.exams.deleteQuestion.tr(args: [exam.title]),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ExamsProvider>().deleteExam(exam.id);
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamsProvider>();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.exams.title.tr(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LoaderWrapper(
              loading: provider.isLoading,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.end,
                          children: [
                            SizedBox(
                              width: 360,
                              child: AppInput(
                                controller: _search,
                                placeholder: AppStrings.exams.searchPlaceholder
                                    .tr(),
                                prefixIcon: const Icon(Icons.search),
                                onChanged: provider.onSearchChanged,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => showAppDialog<Exam>(
                                context: context,
                                content: const ExamFormDialog(),
                              ),
                              icon: const Icon(Icons.add),
                              label: Text(AppStrings.exams.create.tr()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: LoaderWrapper(
                            loading: provider.isUpdating,
                            child: ValueListenableBuilder<List<ExamSummary>>(
                              valueListenable: provider.exams,
                              builder: (context, exams, _) {
                                if (exams.isEmpty) {
                                  return Center(
                                    child: Text(AppStrings.exams.empty.tr()),
                                  );
                                }
                                return ListView.separated(
                                  itemCount: exams.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final exam = exams[index];
                                    return _ExamTile(
                                      exam: exam,
                                      onDelete: () => _delete(exam),
                                      onOpen: () => showAppDialog<void>(
                                        context: context,
                                        content: ExamDetailsDialog(
                                          examId: exam.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
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
                              onPressed: provider.hasNext
                                  ? provider.nextPage
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  const _ExamTile({
    required this.exam,
    required this.onOpen,
    required this.onDelete,
  });
  final ExamSummary exam;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final start = DateFormat('dd.MM.yyyy HH:mm').format(exam.startAt.toLocal());
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListTile(
        onTap: onOpen,
        title: Text(exam.title),
        subtitle: Text(
          '${exam.theme}\n$start • ${exam.durationMinutes} '
          '${AppStrings.exams.minutes.tr()}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
