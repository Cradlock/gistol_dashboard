import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/session.dart';

/// Цветная метка статуса попытки. Сданная, но ещё не до конца проверенная
/// попытка показывается отдельной меткой «Требует проверки».
class SessionStatusBadge extends StatelessWidget {
  const SessionStatusBadge({
    super.key,
    required this.status,
    required this.needsReview,
  });

  final SessionStatus status;
  final bool needsReview;

  String get _label {
    if (needsReview) return AppStrings.exams.needsReview;
    return switch (status) {
      SessionStatus.started => AppStrings.exams.statusStarted,
      SessionStatus.submitted => AppStrings.exams.statusSubmitted,
      SessionStatus.expired => AppStrings.exams.statusExpired,
    };
  }

  Color _color(ThemeData theme) {
    if (needsReview) return Colors.orange.shade800;
    return switch (status) {
      SessionStatus.started => theme.colorScheme.outline,
      SessionStatus.submitted => Colors.green.shade700,
      SessionStatus.expired => theme.colorScheme.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label.tr(),
        style: theme.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
