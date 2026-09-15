import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/tasks/domain/task.dart';
import 'package:gistol_dashboard/features/tasks/view/provider.dart';
import 'package:provider/provider.dart';

class AddTaskCard extends StatefulWidget {
  const AddTaskCard({super.key});

  @override
  State<AddTaskCard> createState() => _AddTaskCardState();
}

class _AddTaskCardState extends State<AddTaskCard> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _pointsController = TextEditingController(text: '1');
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  int? _selectedGroupId;
  Group? _selectedGroup;
  DateTime? _startAt;
  DateTime? _endAt;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pointsController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  String? get _titleError {
    if (!_isSubmitted) return null;
    if (_titleController.text.trim().length < 2) {
      return AppStrings.common.errorBlankInput.tr();
    }
    return null;
  }

  String? get _groupError {
    if (!_isSubmitted) return null;
    if (_selectedGroupId == null) {
      return AppStrings.common.errorBlankInput.tr();
    }
    return null;
  }

  String? get _contentError {
    if (!_isSubmitted) return null;
    if (_contentController.text.trim().isEmpty) {
      return AppStrings.common.errorBlankInput.tr();
    }
    return null;
  }

  String? get _pointsError {
    if (!_isSubmitted) return null;
    final points = int.tryParse(_pointsController.text.trim());
    if (points == null || points < 1) {
      return AppStrings.common.errorBlankInput.tr();
    }
    return null;
  }

  String? get _dateError {
    if (!_isSubmitted) return null;
    if (_startAt == null || _endAt == null) {
      return AppStrings.common.errorBlankInput.tr();
    }
    if (!_endAt!.isAfter(_startAt!)) {
      return AppStrings.tasks.dateRangeInvalid.tr();
    }
    return null;
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _format(DateTime? value) {
    if (value == null) return '';
    return DateFormat('dd.MM.yyyy HH:mm').format(value);
  }

  Future<void> _submit(BuildContext context) async {
    setState(() => _isSubmitted = true);
    if (_titleError != null ||
        _contentError != null ||
        _groupError != null ||
        _pointsError != null ||
        _dateError != null) {
      return;
    }

    final provider = context.read<TasksProvider>();
    try {
      await provider.addTask(
        TaskWriteRequest(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          groupId: _selectedGroupId!,
          startAt: _startAt!,
          endAt: _endAt!,
          points: int.parse(_pointsController.text.trim()),
        ),
      );
      if (!context.mounted) return;
      Navigator.pop(context);
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(context, DateTime.now()),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _titleController,
                label: AppStrings.tasks.addPlaceholderTitle.tr(),
                placeholder: AppStrings.tasks.addPlaceholderTitle.tr(),
                errorText: _titleError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _contentController,
                label: AppStrings.tasks.addPlaceholderContent.tr(),
                placeholder: AppStrings.tasks.addPlaceholderContent.tr(),
                errorText: _contentError,
                maxLines: 5,
                formatters: [LengthLimitingTextInputFormatter(4000)],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              GroupPickerField(
                value: _selectedGroup,
                label: AppStrings.tasks.addPlaceholderGroup.tr(),
                placeholder: AppStrings.tasks.addPlaceholderGroup.tr(),
                errorText: _groupError,
                onChanged: (value) => setState(() {
                  _selectedGroup = value;
                  _selectedGroupId = value?.id;
                }),
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                label: AppStrings.tasks.addPlaceholderPoints.tr(),
                placeholder: AppStrings.tasks.addPlaceholderPoints.tr(),
                errorText: _pointsError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _startController,
                label: AppStrings.tasks.startAt.tr(),
                placeholder: AppStrings.tasks.startAt.tr(),
                errorText: _dateError,
                onTap: () async {
                  final value = await _pickDateTime(_startAt);
                  if (value != null) {
                    setState(() {
                      _startAt = value;
                      _startController.text = _format(value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _endController,
                label: AppStrings.tasks.endAt.tr(),
                placeholder: AppStrings.tasks.endAt.tr(),
                onTap: () async {
                  final value = await _pickDateTime(_endAt);
                  if (value != null) {
                    setState(() {
                      _endAt = value;
                      _endController.text = _format(value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              LoaderWrapper(
                loading: tasksProvider.isOperationLoading,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppBtn(
                      onPressed: () => Navigator.pop(context),
                      type: AppButtonType.text,
                      text: AppStrings.common.cancel.tr(),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _submit(context),
                      child: Text(AppStrings.common.create.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
