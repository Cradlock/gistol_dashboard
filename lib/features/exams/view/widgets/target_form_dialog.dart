import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';

class TargetFormDialog extends StatefulWidget {
  const TargetFormDialog({super.key, this.target, this.group});
  final ExamTarget? target;
  final Group? group;

  @override
  State<TargetFormDialog> createState() => _TargetFormDialogState();
}

class _TargetFormDialogState extends State<TargetFormDialog> {
  late int _year;
  Group? _group;
  int? _groupId;

  @override
  void initState() {
    super.initState();
    _year = widget.target?.year ?? widget.group?.year ?? 1;
    _group = widget.group;
    _groupId = widget.target?.groupId ?? widget.group?.id;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.target == null
                ? AppStrings.exams.addTarget.tr()
                : AppStrings.exams.editTarget.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          AppDropdown<int>(
            value: _year,
            items: const [1, 2, 3, 4, 5, 6],
            itemAsString: (year) => year.toString(),
            label: AppStrings.exams.year.tr(),
            placeholder: AppStrings.exams.year.tr(),
            onChanged: (value) => setState(() {
              _year = value!;
              if (_group?.year != _year) {
                _group = null;
                _groupId = null;
              }
            }),
          ),
          const SizedBox(height: 16),
          GroupPickerField(
            value: _group,
            year: _year,
            allowClear: true,
            label: AppStrings.exams.group.tr(),
            placeholder: _groupId == null
                ? AppStrings.exams.entireYear.tr()
                : '${AppStrings.exams.group.tr()} #$_groupId',
            onChanged: (value) => setState(() {
              _group = value;
              _groupId = value?.id;
            }),
          ),
          if (_groupId != null)
            TextButton(
              onPressed: () => setState(() {
                _group = null;
                _groupId = null;
              }),
              child: Text(AppStrings.exams.useEntireYear.tr()),
            ),
          const SizedBox(height: 8),
          Text(
            AppStrings.exams.groupOptional.tr(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.common.cancel.tr()),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  TargetWriteRequest(year: _year, groupId: _groupId),
                ),
                child: Text(AppStrings.common.save.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
