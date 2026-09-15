import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/tasks/domain/task.dart';
import 'package:gistol_dashboard/features/tasks/view/provider.dart';
import 'package:provider/provider.dart';

class TaskDetailsCard extends StatefulWidget {
  final SituationTask task;

  const TaskDetailsCard({super.key, required this.task});

  @override
  State<TaskDetailsCard> createState() => _TaskDetailsCardState();
}

class _TaskDetailsCardState extends State<TaskDetailsCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<TasksProvider>().loadAnswers(widget.task.id);
      } on AppException catch (e) {
        ErrorHandler.handle(e);
      }
    });
  }

  String _groupTitle(List<Group> groups) {
    for (final group in groups) {
      if (group.id == widget.task.groupId) return group.title;
    }
    return '#${widget.task.groupId}';
  }

  String _statusKey(AnswerStatus status) {
    switch (status) {
      case AnswerStatus.pending:
        return AppStrings.tasks.statusPending;
      case AnswerStatus.positive:
        return AppStrings.tasks.statusPositive;
      case AnswerStatus.negative:
        return AppStrings.tasks.statusNegative;
    }
  }

  Future<void> _grade(int answerId, AnswerStatus status) async {
    try {
      await context.read<TasksProvider>().reviewAnswer(answerId, status);
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksProvider = context.watch<TasksProvider>();
    final groups = context.watch<GroupProvider>().groups.value;
    final task = widget.task;
    final range =
        '${DateFormat('dd.MM.yyyy HH:mm').format(task.startAt.toLocal())} — ${DateFormat('dd.MM.yyyy HH:mm').format(task.endAt.toLocal())}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 560,
          height: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.tasks.details.tr(),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(task.title, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 110),
                child: SingleChildScrollView(child: Text(task.content)),
              ),
              const SizedBox(height: 8),
              Text('${AppStrings.tasks.group.tr()}: ${_groupTitle(groups)}'),
              Text('${AppStrings.tasks.points.tr()}: ${task.points}'),
              Text(range, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              Text(
                AppStrings.tasks.answers.tr(),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LoaderWrapper(
                  loading: tasksProvider.isAnswersLoading,
                  child: ValueListenableBuilder<List<StudentAnswer>>(
                    valueListenable: tasksProvider.answers,
                    builder: (context, answers, child) {
                      if (answers.isEmpty) {
                        return Center(
                          child: Text(AppStrings.tasks.answersEmpty.tr()),
                        );
                      }
                      return ListView.separated(
                        itemCount: answers.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final answer = answers[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(answer.text),
                            subtitle: Text(
                              '${AppStrings.tasks.student.tr()} ${answer.userId} • ${_statusKey(answer.status).tr()}',
                            ),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  tooltip: AppStrings.tasks.gradePending.tr(),
                                  onPressed: () =>
                                      _grade(answer.id, AnswerStatus.pending),
                                  icon: Icon(
                                    Icons.hourglass_empty,
                                    color: answer.status == AnswerStatus.pending
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                ),
                                IconButton(
                                  tooltip: AppStrings.tasks.gradePositive.tr(),
                                  onPressed: () =>
                                      _grade(answer.id, AnswerStatus.positive),
                                  icon: Icon(
                                    Icons.check_circle_outline,
                                    color:
                                        answer.status == AnswerStatus.positive
                                        ? Colors.green
                                        : null,
                                  ),
                                ),
                                IconButton(
                                  tooltip: AppStrings.tasks.gradeNegative.tr(),
                                  onPressed: () =>
                                      _grade(answer.id, AnswerStatus.negative),
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color:
                                        answer.status == AnswerStatus.negative
                                        ? theme.colorScheme.error
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: AppBtn(
                  type: AppButtonType.text,
                  text: AppStrings.common.ok.tr(),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
