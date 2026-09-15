import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:provider/provider.dart';

class SessionReviewDialog extends StatefulWidget {
  const SessionReviewDialog({super.key, required this.sessionId});
  final int sessionId;

  @override
  State<SessionReviewDialog> createState() => _SessionReviewDialogState();
}

class _SessionReviewDialogState extends State<SessionReviewDialog> {
  TeacherSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _session = await context.read<ExamsProvider>().getSession(
        widget.sessionId,
      );
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _review(TeacherAnswer answer, bool accepted) async {
    setState(() => _loading = true);
    try {
      _session = await context.read<ExamsProvider>().reviewAnswer(
        widget.sessionId,
        answer.id,
        accepted,
      );
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _date(DateTime? value) => value == null
      ? '—'
      : DateFormat('dd.MM.yyyy HH:mm').format(value.toLocal());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 760,
      height: 680,
      child: _loading && _session == null
          ? const Center(child: StandardSpinner())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppStrings.exams.session.tr()} #${widget.sessionId}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: _loading ? null : _load,
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (_session case final session?) ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Text(
                        '${AppStrings.exams.user.tr()}: '
                        '${session.studentName ?? '#${session.userId}'}',
                      ),
                      Text(
                        '${AppStrings.exams.status.tr()}: ${session.status}',
                      ),
                      Text(
                        '${AppStrings.exams.score.tr()}: ${session.score ?? '—'}',
                      ),
                      Text(
                        '${AppStrings.exams.started.tr()}: ${_date(session.startedAt)}',
                      ),
                      Text(
                        '${AppStrings.exams.submitted.tr()}: ${_date(session.submittedAt)}',
                      ),
                      Text(
                        '${AppStrings.exams.reviewed.tr()}: ${_date(session.reviewedAt)}',
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.separated(
                          itemCount: session.answers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final answer = session.answers[index];
                            final isInput =
                                answer.questionType == QuestionType.input;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      answer.questionText,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isInput
                                          ? (answer.text ?? '—')
                                          : (answer.choiceText ?? '—'),
                                    ),
                                    Text(
                                      '${AppStrings.exams.awarded.tr()}: '
                                      '${answer.awardedPoints ?? '—'} / ${answer.questionPoints}',
                                    ),
                                    if (!isInput)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          AppStrings.exams.autoGraded.tr(),
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Wrap(
                                          spacing: 8,
                                          children: [
                                            FilledButton.tonalIcon(
                                              onPressed: _loading
                                                  ? null
                                                  : () => _review(answer, true),
                                              icon: const Icon(Icons.check),
                                              label: Text(
                                                AppStrings.exams.accept.tr(),
                                              ),
                                            ),
                                            FilledButton.tonalIcon(
                                              onPressed: _loading
                                                  ? null
                                                  : () =>
                                                        _review(answer, false),
                                              icon: const Icon(Icons.close),
                                              label: Text(
                                                AppStrings.exams.reject.tr(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                  ),
                ],
              ],
            ),
    );
  }
}
