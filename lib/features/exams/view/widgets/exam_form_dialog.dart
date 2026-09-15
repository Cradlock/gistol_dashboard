import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:provider/provider.dart';

class ExamFormDialog extends StatefulWidget {
  const ExamFormDialog({super.key, this.exam});
  final Exam? exam;

  @override
  State<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<ExamFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _theme;
  late final TextEditingController _duration;
  final _start = TextEditingController();
  late DateTime _startAt;
  bool _submitted = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.exam?.title);
    _theme = TextEditingController(text: widget.exam?.theme);
    _duration = TextEditingController(
      text: widget.exam?.durationMinutes.toString() ?? '60',
    );
    _startAt =
        widget.exam?.startAt.toLocal() ??
        DateTime.now().add(const Duration(hours: 1));
    _start.text = _format(_startAt);
  }

  String _format(DateTime value) =>
      DateFormat('dd.MM.yyyy HH:mm').format(value);

  String? _required(String value) => _submitted && value.trim().isEmpty
      ? AppStrings.common.errorBlankInput.tr()
      : null;

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (time == null) return;
    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _start.text = _format(_startAt);
    });
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final duration = int.tryParse(_duration.text);
    if (_title.text.trim().isEmpty ||
        _theme.text.trim().isEmpty ||
        duration == null ||
        duration < 1) {
      return;
    }
    setState(() => _saving = true);
    try {
      final provider = context.read<ExamsProvider>();
      final request = ExamWriteRequest(
        title: _title.text.trim(),
        theme: _theme.text.trim(),
        startAt: _startAt,
        durationMinutes: duration,
      );
      final exam = widget.exam == null
          ? await provider.createExam(request)
          : await provider.updateExam(widget.exam!.id, request);
      if (mounted) Navigator.pop(context, exam);
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _theme.dispose();
    _duration.dispose();
    _start.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exam == null
                  ? AppStrings.exams.create.tr()
                  : AppStrings.exams.edit.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: _title,
              placeholder: AppStrings.exams.titleField.tr(),
              errorText: _required(_title.text),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            AppInput(
              controller: _theme,
              placeholder: AppStrings.exams.theme.tr(),
              maxLines: 3,
              errorText: _required(_theme.text),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            AppInput(
              controller: _start,
              placeholder: AppStrings.exams.startAt.tr(),
              onTap: _pickStart,
            ),
            const SizedBox(height: 12),
            AppInput(
              controller: _duration,
              placeholder: AppStrings.exams.duration.tr(),
              keyboardType: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: _submitted && (int.tryParse(_duration.text) ?? 0) < 1
                  ? AppStrings.exams.positiveNumber.tr()
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: Text(AppStrings.common.cancel.tr()),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppStrings.common.save.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
