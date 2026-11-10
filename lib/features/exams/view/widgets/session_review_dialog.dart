import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/domain/session.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/session_status_badge.dart';
import 'package:provider/provider.dart';

/// Ответы одного студента с возможностью проверки.
///
/// Вопросы с выбором проверены автоматически (только просмотр).
/// Текстовые ответы преподаватель принимает («Верно» — полный балл)
/// или отклоняет («Неверно» — 0 баллов). Решение можно изменить.
class SessionReviewDialog extends StatefulWidget {
  const SessionReviewDialog({
    super.key,
    required this.sessionId,
    required this.exam,
  });

  final int sessionId;
  final Exam exam;

  @override
  State<SessionReviewDialog> createState() => _SessionReviewDialogState();
}

class _SessionReviewDialogState extends State<SessionReviewDialog> {
  TeacherSessionDetail? _session;
  bool _loading = true;
  bool _failed = false;
  int? _busyAnswerId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  int get _maxScore =>
      widget.exam.questions.fold<int>(0, (sum, item) => sum + item.points);

  String? _expectedAnswer(int questionId) {
    for (final question in widget.exam.questions) {
      if (question.id == questionId) return question.expectedAnswer;
    }
    return null;
  }

  Future<void> _load() async {
    final provider = context.read<ExamsProvider>();
    if (!_loading) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }
    try {
      final session = await provider.getSession(widget.sessionId);
      if (mounted) setState(() => _session = session);
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() => _failed = true);
      ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _review(TeacherAnswer answer, bool accepted) async {
    // Повторный клик по уже выбранному решению ничего не меняет.
    if (answer.isReviewed && answer.isAccepted == accepted) return;
    final provider = context.read<ExamsProvider>();
    setState(() => _busyAnswerId = answer.id);
    try {
      final updated = await provider.reviewAnswer(
        widget.sessionId,
        answer.id,
        accepted: accepted,
      );
      if (mounted) setState(() => _session = updated);
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _busyAnswerId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = _session;

    return SizedBox(
      width: 760,
      height: 680,
      child: session == null
          ? _stateBody()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(theme, session),
                SizedBox(
                  height: 4,
                  child: _busyAnswerId != null
                      ? const LinearProgressIndicator()
                      : null,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: session.answers.isEmpty
                      ? Center(child: Text(AppStrings.exams.noAnswer.tr()))
                      : ListView.separated(
                          itemCount: session.answers.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) => _answerTile(
                            theme,
                            session,
                            index,
                            session.answers[index],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  /// Состояние, пока попытка не загружена: спиннер или ошибка с повтором.
  Widget _stateBody() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ),
        Expanded(
          child: Center(
            child: _loading || !_failed
                ? const StandardSpinner()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.exams.loadFailed.tr()),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _load,
                        child: Text(AppStrings.common.retry.tr()),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _header(ThemeData theme, TeacherSessionDetail session) {
    final name =
        session.studentName ??
        '${AppStrings.exams.student.tr()} #${session.userId}';
    final reviewable = session.reviewableAnswers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, style: theme.textTheme.titleLarge)),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Text(session.examTitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SessionStatusBadge(
              status: session.status,
              needsReview: session.needsReview,
            ),
            if (session.score != null)
              Text(
                '${AppStrings.exams.score.tr()}: '
                '${session.score} / $_maxScore',
                style: theme.textTheme.titleSmall,
              ),
            if (session.canReview && reviewable > 0)
              Text(
                AppStrings.exams.reviewProgress.tr(
                  args: ['${session.reviewedCount}', '$reviewable'],
                ),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        if (session.status == SessionStatus.started)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppStrings.exams.reviewUnavailable.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }

  Widget _answerTile(
    ThemeData theme,
    TeacherSessionDetail session,
    int index,
    TeacherAnswer answer,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelMedium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  answer.questionText,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: 12),
              _pointsLabel(theme, answer),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: answer.isInput
                ? _inputAnswer(theme, session, answer)
                : _choiceAnswer(theme, answer),
          ),
        ],
      ),
    );
  }

  Widget _pointsLabel(ThemeData theme, TeacherAnswer answer) {
    final points = AppStrings.exams.points.tr();
    final awarded = answer.awardedPoints;
    final text = awarded == null
        ? '${answer.questionPoints} $points'
        : '$awarded / ${answer.questionPoints} $points';
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.outline,
      ),
    );
  }

  Widget _noAnswer(ThemeData theme) => Text(
    AppStrings.exams.noAnswer.tr(),
    style: theme.textTheme.bodyMedium?.copyWith(
      fontStyle: FontStyle.italic,
      color: theme.colorScheme.outline,
    ),
  );

  Widget _choiceAnswer(ThemeData theme, TeacherAnswer answer) {
    if (!answer.isAnswered) return _noAnswer(theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final choice in answer.choices)
          _choiceRow(theme, choice, selected: choice.id == answer.choiceId),
      ],
    );
  }

  Widget _choiceRow(
    ThemeData theme,
    ExamChoice choice, {
    required bool selected,
  }) {
    final correctColor = Colors.green.shade700;
    final Color? color = choice.isCorrect
        ? correctColor
        : (selected ? theme.colorScheme.error : null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              choice.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ),
          if (choice.isCorrect)
            Icon(Icons.check_circle, size: 18, color: correctColor)
          else if (selected)
            Icon(Icons.cancel, size: 18, color: theme.colorScheme.error),
        ],
      ),
    );
  }

  Widget _inputAnswer(
    ThemeData theme,
    TeacherSessionDetail session,
    TeacherAnswer answer,
  ) {
    final expected = _expectedAnswer(answer.questionId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.exams.studentAnswer.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: answer.text == null
              ? _noAnswer(theme)
              : SelectableText(answer.text!),
        ),
        if (expected != null) ...[
          const SizedBox(height: 6),
          Text(
            '${AppStrings.exams.expectedAnswer.tr()}: $expected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
            ),
          ),
        ],
        if (answer.isReviewable) ...[
          const SizedBox(height: 10),
          _reviewButtons(theme, session, answer),
        ],
      ],
    );
  }

  Widget _reviewButtons(
    ThemeData theme,
    TeacherSessionDetail session,
    TeacherAnswer answer,
  ) {
    final enabled = session.canReview && _busyAnswerId == null;

    return Row(
      children: [
        _decisionButton(
          selected: answer.isAccepted,
          icon: Icons.check_circle_outline,
          label: AppStrings.exams.accept,
          color: Colors.green.shade700,
          onPressed: enabled ? () => _review(answer, true) : null,
        ),
        const SizedBox(width: 8),
        _decisionButton(
          selected: answer.isRejected,
          icon: Icons.cancel_outlined,
          label: AppStrings.exams.reject,
          color: theme.colorScheme.error,
          onPressed: enabled ? () => _review(answer, false) : null,
        ),
        const SizedBox(width: 12),
        if (!answer.isReviewed)
          Text(
            AppStrings.exams.awaitingReview.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }

  Widget _decisionButton({
    required bool selected,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final text = Text(label.tr());
    if (selected) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon, size: 18),
        label: text,
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      icon: Icon(icon, size: 18),
      label: text,
    );
  }
}
