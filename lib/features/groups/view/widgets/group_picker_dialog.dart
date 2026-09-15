import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/domain/filter.dart';
import 'package:gistol_dashboard/features/groups/domain/group.dart';
import 'package:gistol_dashboard/features/groups/services/main.dart';

Future<Group?> showGroupPicker({
  required BuildContext context,
  Group? selectedGroup,
  int? year,
}) {
  return showAppDialog<Group>(
    context: context,
    content: GroupPickerDialog(selectedGroup: selectedGroup, year: year),
  );
}

class GroupPickerField extends StatelessWidget {
  final Group? value;
  final ValueChanged<Group?> onChanged;
  final String? label;
  final String? placeholder;
  final String? errorText;
  final int? year;
  final bool allowClear;

  const GroupPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.errorText,
    this.year,
    this.allowClear = false,
  });

  Future<void> _open(BuildContext context) async {
    final group = await showGroupPicker(
      context: context,
      selectedGroup: value,
      year: year,
    );
    if (group != null) onChanged(group);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = label ?? placeholder;

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: caption,
          hintText: value == null ? placeholder : null,
          errorText: errorText,
          filled: true,
          fillColor: theme.colorScheme.surface,
          prefixIcon: const Icon(Icons.groups_outlined),
          suffixIcon: allowClear && value != null
              ? IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: () => onChanged(null),
                  icon: const Icon(Icons.close),
                )
              : const Icon(Icons.chevron_right),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ),
        child: Text(
          value?.title ?? '',
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class GroupPickerDialog extends StatefulWidget {
  final Group? selectedGroup;
  final int? year;

  const GroupPickerDialog({super.key, this.selectedGroup, this.year});

  @override
  State<GroupPickerDialog> createState() => _GroupPickerDialogState();
}

class _GroupPickerDialogState extends State<GroupPickerDialog> {
  final _service = GroupService();
  final _searchController = TextEditingController();

  Timer? _debounce;
  List<Group> _groups = [];
  bool _isLoading = false;
  SortField _sortField = SortField.groupTitle;
  SortOrder _sortOrder = SortOrder.minToMax;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchGroups() async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.getGroups(
        1,
        100,
        FilterParams(
          sortType: _sortOrder,
          sortField: _sortField,
          title: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          minYear: widget.year,
          maxYear: widget.year,
        ),
      );
      if (!mounted) return;
      setState(() => _groups = response.data?.groups ?? []);
    } on AppException catch (error) {
      ErrorHandler.handle(error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetchGroups);
  }

  Future<void> _setSortField(SortField? value) async {
    if (value == null) return;
    setState(() => _sortField = value);
    await _fetchGroups();
  }

  Future<void> _setSortOrder(SortOrder? value) async {
    if (value == null) return;
    setState(() => _sortOrder = value);
    await _fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      height: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.groups.selectGroup.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppInput(
            controller: _searchController,
            prefixIcon: const Icon(Icons.search),
            placeholder: AppStrings.groups.searchPlaceholder.tr(),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown<SortField>(
                  value: _sortField,
                  items: const [SortField.groupTitle, SortField.date],
                  itemAsString: (item) => item.trKey.tr(),
                  label: AppStrings.groups.sortField.tr(),
                  placeholder: AppStrings.groups.sortField.tr(),
                  onChanged: _setSortField,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown<SortOrder>(
                  value: _sortOrder,
                  items: SortOrder.values,
                  itemAsString: (item) => item.trKey.tr(),
                  label: AppStrings.groups.sortOrder.tr(),
                  placeholder: AppStrings.groups.sortOrder.tr(),
                  onChanged: _setSortOrder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: StandardSpinner())
                : _groups.isEmpty
                ? Center(child: Text(AppStrings.groups.empty.tr()))
                : ListView.separated(
                    itemCount: _groups.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final group = _groups[index];
                      final selected = group.id == widget.selectedGroup?.id;
                      return ListTile(
                        selected: selected,
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(group.title),
                        subtitle: Text(
                          '${AppStrings.groups.course.tr()} ${group.year}',
                        ),
                        onTap: () => Navigator.pop(context, group),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
