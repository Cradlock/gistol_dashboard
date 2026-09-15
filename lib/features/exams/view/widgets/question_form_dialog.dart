import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';

class QuestionFormDialog extends StatefulWidget {
  const QuestionFormDialog({
    super.key,
    this.question,
    this.initialPosition = 0,
  });
  final ExamQuestion? question;
  final int initialPosition;

  @override
  State<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<QuestionFormDialog> {
  late final TextEditingController _text;
  late final TextEditingController _points;
  late final TextEditingController _position;
  late final TextEditingController _expected;
  late QuestionType _type;
  final List<TextEditingController> _choices = [];
  int _correctIndex = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final item = widget.question;
    _text = TextEditingController(text: item?.text);
    _points = TextEditingController(text: '${item?.points ?? 1}');
    _position = TextEditingController(
      text: '${item?.position ?? widget.initialPosition}',
    );
    _expected = TextEditingController(text: item?.expectedAnswer);
    _type = item?.type ?? QuestionType.choice;
    if (item != null && item.choices.isNotEmpty) {
      for (var i = 0; i < item.choices.length; i++) {
        _choices.add(TextEditingController(text: item.choices[i].text));
        if (item.choices[i].isCorrect) _correctIndex = i;
      }
    } else {
      _choices.addAll([TextEditingController(), TextEditingController()]);
    }
  }

  bool get _valid {
    if (_text.text.trim().isEmpty ||
        (int.tryParse(_points.text) ?? 0) < 1 ||
        (int.tryParse(_position.text) ?? -1) < 0) {
      return false;
    }
    if (_type == QuestionType.input) return _expected.text.trim().isNotEmpty;
    return _choices.length >= 2 &&
        _choices.every((item) => item.text.trim().isNotEmpty) &&
        _correctIndex >= 0 &&
        _correctIndex < _choices.length;
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_valid) return;
    Navigator.pop(
      context,
      QuestionWriteRequest(
        text: _text.text.trim(),
        type: _type,
        points: int.parse(_points.text),
        position: int.parse(_position.text),
        choices: _type == QuestionType.choice
            ? [
                for (var i = 0; i < _choices.length; i++)
                  ChoiceWriteRequest(
                    text: _choices[i].text.trim(),
                    isCorrect: i == _correctIndex,
                  ),
              ]
            : const [],
        expectedAnswer: _type == QuestionType.input
            ? _expected.text.trim()
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _text.dispose();
    _points.dispose();
    _position.dispose();
    _expected.dispose();
    for (final controller in _choices) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _submitted && !_valid
        ? AppStrings.exams.questionInvalid.tr()
        : null;
    return SizedBox(
      width: 560,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 680),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.question == null
                    ? AppStrings.exams.addQuestion.tr()
                    : AppStrings.exams.editQuestion.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SegmentedButton<QuestionType>(
                segments: [
                  ButtonSegment(
                    value: QuestionType.choice,
                    label: Text(AppStrings.exams.choice.tr()),
                  ),
                  ButtonSegment(
                    value: QuestionType.input,
                    label: Text(AppStrings.exams.input.tr()),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) =>
                    setState(() => _type = value.first),
              ),
              const SizedBox(height: 12),
              AppInput(
                controller: _text,
                label: AppStrings.exams.questionText.tr(),
                placeholder: AppStrings.exams.questionText.tr(),
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      controller: _points,
                      label: AppStrings.exams.points.tr(),
                      placeholder: AppStrings.exams.points.tr(),
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInput(
                      controller: _position,
                      label: AppStrings.exams.position.tr(),
                      placeholder: AppStrings.exams.position.tr(),
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_type == QuestionType.input)
                AppInput(
                  controller: _expected,
                  label: AppStrings.exams.expectedAnswer.tr(),
                  placeholder: AppStrings.exams.expectedAnswer.tr(),
                  onChanged: (_) => setState(() {}),
                )
              else ...[
                for (var i = 0; i < _choices.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: AppStrings.exams.correctChoice.tr(),
                          onPressed: () => setState(() => _correctIndex = i),
                          icon: Icon(
                            i == _correctIndex
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                        ),
                        Expanded(
                          child: AppInput(
                            controller: _choices[i],
                            label: '${AppStrings.exams.choice.tr()} ${i + 1}',
                            placeholder:
                                '${AppStrings.exams.choice.tr()} ${i + 1}',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        IconButton(
                          onPressed: _choices.length <= 2
                              ? null
                              : () => setState(() {
                                  _choices.removeAt(i).dispose();
                                  if (_correctIndex >= _choices.length) {
                                    _correctIndex = 0;
                                  }
                                }),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ],
                    ),
                  ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _choices.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: Text(AppStrings.exams.addChoice.tr()),
                ),
              ],
              if (error != null)
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppStrings.common.cancel.tr()),
                  ),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(AppStrings.common.save.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
