import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exam_form_dialog.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/question_form_dialog.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/session_review_dialog.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/target_form_dialog.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:provider/provider.dart';

class ExamDetailsDialog extends StatefulWidget {
  const ExamDetailsDialog({super.key, required this.examId});
  final int examId;

  @override
  State<ExamDetailsDialog> createState() => _ExamDetailsDialogState();
}

class _ExamDetailsDialogState extends State<ExamDetailsDialog> {
  Exam? _exam;
  List<ExamSessionSummary> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final provider = context.read<ExamsProvider>();
      final results = await Future.wait<dynamic>([
        provider.getExam(widget.examId),
        provider.getSessions(widget.examId),
      ]);
      _exam = results[0] as Exam;
      _sessions = results[1] as List<ExamSessionSummary>;
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<Exam> Function() action) async {
    setState(() => _loading = true);
    try {
      _exam = await action();
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Group? _group(int? id) {
    if (id == null) return null;
    for (final group in context.read<GroupProvider>().groups.value) {
      if (group.id == id) return group;
    }
    return null;
  }

  int _nextQuestionPosition() {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    if (questions.isEmpty) return 0;
    return questions
            .map((question) => question.position)
            .reduce((left, right) => left > right ? left : right) +
        1;
  }

  Future<void> _editMetadata() async {
    final result = await showAppDialog<Exam>(
      context: context,
      content: ExamFormDialog(exam: _exam),
    );
    if (result != null) setState(() => _exam = result);
  }

  Future<void> _editTarget([ExamTarget? target]) async {
    final request = await showAppDialog<TargetWriteRequest>(
      context: context,
      content: TargetFormDialog(target: target, group: _group(target?.groupId)),
    );
    if (request == null || _exam == null) return;
    await _run(
      () => context.read<ExamsProvider>().saveTarget(
        _exam!,
        request,
        targetId: target?.id,
      ),
    );
  }

  Future<void> _editQuestion([ExamQuestion? question]) async {
    final request = await showAppDialog<QuestionWriteRequest>(
      context: context,
      content: QuestionFormDialog(
        question: question,
        initialPosition: _nextQuestionPosition(),
      ),
    );
    if (request == null || _exam == null) return;
    await _run(
      () => context.read<ExamsProvider>().saveQuestion(
        _exam!,
        request,
        questionId: question?.id,
      ),
    );
  }

  String _date(DateTime value) =>
      DateFormat('dd.MM.yyyy HH:mm').format(value.toLocal());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 900,
      height: 720,
      child: _loading && _exam == null
          ? const Center(child: StandardSpinner())
          : Stack(
              children: [
                if (_exam case final exam?)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exam.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: AppStrings.exams.edit.tr(),
                            onPressed: _editMetadata,
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Text(exam.theme),
                      Text(
                        '${_date(exam.startAt)} • '
                        '${exam.durationMinutes} ${AppStrings.exams.minutes.tr()}',
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              TabBar(
                                tabs: [
                                  Tab(text: AppStrings.exams.targets.tr()),
                                  Tab(text: AppStrings.exams.questions.tr()),
                                  Tab(text: AppStrings.exams.sessions.tr()),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _targets(exam),
                                    _questions(exam),
                                    _sessionList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_loading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x22000000),
                      child: Center(child: StandardSpinner()),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _targets(Exam exam) => Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => _editTarget(),
          icon: const Icon(Icons.add),
          label: Text(AppStrings.exams.addTarget.tr()),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: exam.targets.length,
          itemBuilder: (context, index) {
            final target = exam.targets[index];
            final group = _group(target.groupId);
            return ListTile(
              title: Text(
                group?.title ??
                    (target.groupId == null
                        ? AppStrings.exams.entireYear.tr()
                        : '${AppStrings.exams.group.tr()} #${target.groupId}'),
              ),
              subtitle: Text('${AppStrings.exams.year.tr()} ${target.year}'),
              onTap: () => _editTarget(target),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _run(
                  () => context.read<ExamsProvider>().deleteTarget(
                    exam,
                    target.id,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _questions(Exam exam) => Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => _editQuestion(),
          icon: const Icon(Icons.add),
          label: Text(AppStrings.exams.addQuestion.tr()),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: exam.questions.length,
          itemBuilder: (context, index) {
            final question = exam.questions[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${question.position}')),
              title: Text(question.text),
              subtitle: Text(
                '${question.type.value} • ${question.points} '
                '${AppStrings.exams.points.tr()}',
              ),
              onTap: () => _editQuestion(question),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _run(
                  () => context.read<ExamsProvider>().deleteQuestion(
                    exam,
                    question.id,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _sessionList() => RefreshIndicator(
    onRefresh: _load,
    child: ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(
            '${session.studentName ?? '${AppStrings.exams.user.tr()} ${session.userId}'} • '
            '${session.status}',
          ),
          subtitle: Text(
            '${_date(session.startedAt)} • '
            '${AppStrings.exams.score.tr()}: ${session.score ?? '—'}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showAppDialog<void>(
            context: context,
            content: SessionReviewDialog(sessionId: session.id),
          ),
        );
      },
    ),
  );
}
