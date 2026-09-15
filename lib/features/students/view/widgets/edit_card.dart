import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/students/domain/student.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:provider/provider.dart';

class EditStudentCard extends StatefulWidget {
  final Student student;

  const EditStudentCard({
    super.key,
    required this.student,
  });

  @override
  State<EditStudentCard> createState() => _EditStudentCardState();
}

class _EditStudentCardState extends State<EditStudentCard> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _scoresController = TextEditingController();

  int? _selectedYear;
  int? _selectedGroupId;
  Group? _selectedGroup;
  bool _isSubmitted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nameController.text = student.name ?? '';
    _surnameController.text = student.surname ?? '';
    _scoresController.text = student.scores.toString();
    _selectedYear = student.year;
    _selectedGroupId = student.group?.id;
    _selectedGroup = student.group;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _scoresController.dispose();
    super.dispose();
  }

  String? get _nameError {
    if (!_isSubmitted) return null;
    if (_nameController.text.trim().isEmpty) {
      return AppStrings.common.errorBlankInput.tr();
    }
    return null;
  }

  String? get _surnameError {
    if (!_isSubmitted) return null;
    if (_surnameController.text.trim().isEmpty) {
      return AppStrings.common.errorBlankInput.tr();
    }
    return null;
  }

  String? get _yearError {
    if (!_isSubmitted) return null;
    if (_selectedYear == null) {
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

  String? get _scoresError {
    if (!_isSubmitted) return null;
    if (_scoresController.text.trim().isEmpty) {
      return AppStrings.common.errorBlankInput.tr();
    }
    return null;
  }

  List<int> _years(GroupProvider groupProvider) {
    final years = List<int>.from(groupProvider.years);
    final studentYear = widget.student.year;
    if (studentYear != null && !years.contains(studentYear)) {
      years.add(studentYear);
      years.sort();
    }
    return years;
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _isSubmitted = true;
    });

    if (_nameError != null ||
        _surnameError != null ||
        _yearError != null ||
        _groupError != null ||
        _scoresError != null) {
      return;
    }

    final provider = context.read<StudentsProvider>();
    final data = StudentUpdate(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      groupId: _selectedGroupId!,
      year: _selectedYear!,
      scores: int.parse(_scoresController.text.trim()),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      await provider.editStudent(widget.student.id, data);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!context.mounted) return;
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
    final groupProvider = context.watch<GroupProvider>();
    final years = _years(groupProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ValueListenableBuilder<List<Group>>(
          valueListenable: groupProvider.groups,
          builder: (context, _, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        (widget.student.name?.trim().isNotEmpty ?? false)
                            ? widget.student.name!.trim()[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            [
                              widget.student.surname,
                              widget.student.name,
                            ]
                                .where(
                                  (part) =>
                                      part != null && part.trim().isNotEmpty,
                                )
                                .join(' '),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'ID: ${widget.student.id} · '
                            '${widget.student.group?.title ?? '—'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: _surnameController,
                  placeholder: AppStrings.students.editPlaceholderSurname.tr(),
                  errorText: _surnameError,
                  formatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-Zа-яА-ЯёЁ\s-]"),
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: _nameController,
                  placeholder: AppStrings.students.editPlaceholderName.tr(),
                  errorText: _nameError,
                  formatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-Zа-яА-ЯёЁ\s-]"),
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                AppDropdown<int>(
                  items: years,
                  value: _selectedYear,
                  itemAsString: (year) => year.toString(),
                  placeholder: AppStrings.students.editPlaceholderYear.tr(),
                  errorText: _yearError,
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                      if (_selectedGroup?.year != value) {
                        _selectedGroupId = null;
                        _selectedGroup = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                GroupPickerField(
                  value: _selectedGroup,
                  year: _selectedYear,
                  placeholder: AppStrings.students.editPlaceholderGroup.tr(),
                  errorText: _groupError,
                  onChanged: (value) {
                    setState(() {
                      _selectedGroupId = value?.id;
                      _selectedGroup = value;
                      if (value != null) _selectedYear = value.year;
                    });
                  },
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: _scoresController,
                  placeholder: AppStrings.students.editPlaceholderScores.tr(),
                  errorText: _scoresError,
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                LocalLoaderWrapper(
                  isLoading: _isLoading,
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
                        child: Text(AppStrings.common.save.tr()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
