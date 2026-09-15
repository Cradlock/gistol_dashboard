import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/core/widgets/label_wrapper.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/students/domain/filter.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:provider/provider.dart';

class StudentFilterCard extends StatefulWidget {
  const StudentFilterCard({super.key});

  @override
  State<StudentFilterCard> createState() => _StudentFilterCardState();
}

class _StudentFilterCardState extends State<StudentFilterCard> {
  bool _isLoading = false;
  int? _minYear;
  int? _maxYear;
  int? _groupId;

  @override
  void initState() {
    super.initState();
    final params = context.read<StudentsProvider>().filterParams;
    _minYear = params.minYear;
    _maxYear = params.maxYear;
    _groupId = params.groupId;
  }

  Future<void> _submit(BuildContext context) async {
    final provider = context.read<StudentsProvider>();
    setState(() {
      _isLoading = true;
    });

    try {
      await provider.updateFilterParams(
        FilterStudentParams(
          sortType: provider.filterParams.sortType,
          sortField: provider.filterParams.sortField,
          fio: provider.filterParams.fio,
          minYear: _minYear,
          maxYear: _maxYear,
          groupId: _groupId,
          confirmed: provider.filterParams.confirmed,
          deleted: provider.filterParams.deleted,
        ),
      );
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

  List<Group> _groupsForYears(List<Group> groups) {
    return groups.where((group) {
      if (_minYear != null && group.year < _minYear!) return false;
      if (_maxYear != null && group.year > _maxYear!) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final years = groupProvider.years;

    return PopScope(
      canPop: !_isLoading,
      child: ValueListenableBuilder<List<Group>>(
        valueListenable: groupProvider.groups,
        builder: (context, groups, _) {
          final groupsForYears = _groupsForYears(groups);
          Group? selectedGroup;
          for (final group in groupsForYears) {
            if (group.id == _groupId) {
              selectedGroup = group;
              break;
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.students.filters.tr()),
                  AppBtn(
                    text: AppStrings.students.resetFilters.tr(),
                    type: AppButtonType.text,
                    onPressed: () async => _reset(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LabelWrapper(
                label: AppStrings.students.filterCourseRangeLabel.tr(),
                child: Row(
                  children: [
                    Expanded(
                      child: AppDropdown<int>(
                        value: years.contains(_minYear) ? _minYear : null,
                        items: years,
                        itemAsString: (i) => i.toString(),
                        label: AppStrings.common.from.tr(),
                        placeholder: AppStrings.common.from.tr(),
                        onChanged: (i) => setState(() {
                          _minYear = i;
                          if (selectedGroup != null &&
                              _minYear != null &&
                              selectedGroup.year < _minYear!) {
                            _groupId = null;
                          }
                        }),
                      ),
                    ),
                    const RangeDivider(),
                    Expanded(
                      child: AppDropdown<int>(
                        value: years.contains(_maxYear) ? _maxYear : null,
                        items: years,
                        itemAsString: (i) => i.toString(),
                        label: AppStrings.common.to.tr(),
                        placeholder: AppStrings.common.to.tr(),
                        onChanged: (i) => setState(() {
                          _maxYear = i;
                          if (selectedGroup != null &&
                              _maxYear != null &&
                              selectedGroup.year > _maxYear!) {
                            _groupId = null;
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LabelWrapper(
                label: AppStrings.students.filterGroupLabel.tr(),
                child: AppDropdown<Group>(
                  items: groupsForYears,
                  value: selectedGroup,
                  itemAsString: (group) => group.title,
                  label: AppStrings.students.filterGroupLabel.tr(),
                  placeholder: AppStrings.students.filterGroupLabel.tr(),
                  onChanged: (group) => setState(() {
                    _groupId = group?.id;
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
          );
        },
      ),
    );
  }
}
