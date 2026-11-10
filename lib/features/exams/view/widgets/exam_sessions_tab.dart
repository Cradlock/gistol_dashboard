import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/domain/session.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/session_review_dialog.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/session_status_badge.dart';
import 'package:provider/provider.dart';

/// Вкладка «Результаты»: список попыток студентов по экзамену.
/// Клик по строке открывает диалог с ответами и проверкой.
class ExamSessionsTab extends StatefulWidget {
  const ExamSessionsTab({super.key, required this.exam});
  final Exam exam;

  @override
  State<ExamSessionsTab> createState() => _ExamSessionsTabState();
}

class _ExamSessionsTabState extends State<ExamSessionsTab>
    with AutomaticKeepAliveClientMixin {
  List<SessionSummary> _sessions = const [];
  bool _loading = true;
  bool _failed = false;
  bool _onlyNeedsReview = false;

  // Не перезагружаем список при каждом переключении вкладок.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load(showLoader: false);
  }

  int get _maxScore =>
      widget.exam.questions.fold<int>(0, (sum, item) => sum + item.points);

  Future<void> _load({bool showLoader = true}) async {
    final provider = context.read<ExamsProvider>();
    if (showLoader) setState(() => _loading = true);
    try {
      final response = await provider.getSessions(widget.exam.id);
      if (!mounted) return;
      setState(() {
        _sessions = response.sessions;
        _failed = false;
      });
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() => _failed = true);
      ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(SessionSummary session) async {
    await showAppDialog<void>(
      context: context,
      content: SessionReviewDialog(sessionId: session.id, exam: widget.exam),
    );
    // Преподаватель мог проверить ответы — подтягиваем свежие оценки.
    if (mounted) await _load(showLoader: false);
  }

  String _date(DateTime value) =>
      DateFormat('dd.MM.yyyy HH:mm').format(value.toLocal());

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final needsReviewCount = _sessions.where((item) => item.needsReview).length;
    final visible = _onlyNeedsReview
        ? _sessions.where((item) => item.needsReview).toList()
        : _sessions;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: Text(
                  '${AppStrings.exams.filterAll.tr()} (${_sessions.length})',
                ),
                selected: !_onlyNeedsReview,
                onSelected: (_) => setState(() => _onlyNeedsReview = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(
                  '${AppStrings.exams.filterNeedsReview.tr()} '
                  '($needsReviewCount)',
                ),
                selected: _onlyNeedsReview,
                onSelected: (_) => setState(() => _onlyNeedsReview = true),
              ),
              const Spacer(),
              IconButton(
                tooltip: AppStrings.exams.refresh.tr(),
                onPressed: _loading ? null : () => _load(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 2,
          child: _loading ? const LinearProgressIndicator() : null,
        ),
        Expanded(child: _body(visible)),
      ],
    );
  }

  Widget _body(List<SessionSummary> visible) {
    if (_loading && _sessions.isEmpty) {
      return const Center(child: StandardSpinner());
    }
    if (_failed && _sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.exams.loadFailed.tr()),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _load(),
              child: Text(AppStrings.common.retry.tr()),
            ),
          ],
        ),
      );
    }
    if (visible.isEmpty) {
      return Center(
        child: Text(
          _onlyNeedsReview
              ? AppStrings.exams.sessionsFilteredEmpty.tr()
              : AppStrings.exams.sessionsEmpty.tr(),
        ),
      );
    }
    return ListView.separated(
      itemCount: visible.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => _tile(visible[index]),
    );
  }

  Widget _tile(SessionSummary session) {
    final theme = Theme.of(context);
    final name =
        session.studentName ??
        '${AppStrings.exams.student.tr()} #${session.userId}';
    final dates = <String>[
      '${AppStrings.exams.attemptStarted.tr()}: ${_date(session.startedAt)}',
      if (session.submittedAt != null)
        '${AppStrings.exams.attemptSubmitted.tr()}: '
            '${_date(session.submittedAt!)}',
    ];

    return ListTile(
      title: Text(name),
      subtitle: Text(
        dates.join(' • '),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      onTap: () => _open(session),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (session.score != null) ...[
            Text(
              '${session.score} / $_maxScore',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(width: 12),
          ],
          SessionStatusBadge(
            status: session.status,
            needsReview: session.needsReview,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
