import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/core/widgets/label_wrapper.dart';
import 'package:gistol_dashboard/features/students/domain/filter.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:provider/provider.dart';

class StudentSortCard extends StatefulWidget {
  const StudentSortCard({super.key});

  @override
  State<StudentSortCard> createState() => _StudentSortCardState();
}

class _StudentSortCardState extends State<StudentSortCard> {
  late SortStudentsOrder _sortOrder;
  late SortStudentsField _sortField;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<StudentsProvider>();
    _sortField = provider.filterParams.sortField;
    _sortOrder = provider.filterParams.sortType;
  }

  Future<void> _submit(BuildContext context) async {
    final provider = context.read<StudentsProvider>();
    setState(() {
      _isLoading = true;
    });

    try {
      final newParams = FilterStudentParams(
        sortType: _sortOrder,
        sortField: _sortField,
        fio: provider.filterParams.fio,
        minYear: provider.filterParams.minYear,
        maxYear: provider.filterParams.maxYear,
        groupId: provider.filterParams.groupId,
        confirmed: provider.filterParams.confirmed,
        deleted: provider.filterParams.deleted,
      );
      await provider.updateFilterParams(newParams);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reset(BuildContext context) async {
    final provider = context.read<StudentsProvider>();
    setState(() {
      _isLoading = true;
    });

    try {
      await provider.resetFilterParams();
      if (!context.mounted) return;
      Navigator.pop(context);
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.students.sort.tr()),
              AppBtn(
                text: AppStrings.students.resetSort.tr(),
                type: AppButtonType.text,
                onPressed: () async => _reset(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LabelWrapper(
            label: AppStrings.students.sortOrder.tr(),
            child: AppDropdown<SortStudentsOrder>(
              items: SortStudentsOrder.values,
              value: _sortOrder,
              itemAsString: (value) => value.trKey.tr(),
              onChanged: (value) => setState(() {
                if (value != null) {
                  _sortOrder = value;
                }
              }),
            ),
          ),
          const SizedBox(height: 16),
          LabelWrapper(
            label: AppStrings.students.sortField.tr(),
            child: AppDropdown<SortStudentsField>(
              value: _sortField,
              items: SortStudentsField.values,
              itemAsString: (item) => item.trKey.tr(),
              onChanged: (value) => setState(() {
                if (value != null) {
                  _sortField = value;
                }
              }),
            ),
          ),
          const SizedBox(height: 16),
          LocalLoaderWrapper(
            isLoading: _isLoading,
            child: Row(
              children: [
                AppBtn(
                  type: AppButtonType.outlined,
                  text: AppStrings.common.cancel.tr(),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                AppBtn(
                  type: AppButtonType.filled,
                  text: AppStrings.common.save.tr(),
                  onPressed: () => _submit(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
