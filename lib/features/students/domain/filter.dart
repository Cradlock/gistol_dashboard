
import 'package:gistol_dashboard/core/core.dart';

enum SortStudentsOrder {
  maxToMin('max_to_min'),
  minToMax('min_to_max');

  final String value;
  const SortStudentsOrder(this.value);
  
}



enum SortStudentsField {
  year("year"),
  scores("scores");

  final String value;
  const SortStudentsField(this.value);
}

extension SortOrderLocalization on SortStudentsOrder {
  String get trKey {
    switch (this) {
      case SortStudentsOrder.maxToMin:
        return AppStrings.groups.maxToMin;
      case SortStudentsOrder.minToMax:
        return AppStrings.groups.minToMax;
    }
  }
}

extension SortFieldLocalization on SortStudentsField {
  String get trKey {
    switch (this) {
      case SortStudentsField.year:
        return AppStrings.students.year_sort_label;
      case SortStudentsField.scores:
        return AppStrings.students.scores_sort_label;
    }
  }
}

class FilterStudentParams {
  final SortStudentsOrder sortType;
  final SortStudentsField sortField;

  final String? fio;
  final int? minYear;
  final int? maxYear;
  final int? groupId;

  final bool confirmed;
  final bool deleted;

  const FilterStudentParams({
    required this.sortType,
    required this.sortField,
    this.fio,
    this.minYear,
    this.maxYear,
    this.groupId,
    this.confirmed = true,
    this.deleted = false,
  });

  FilterStudentParams copyWith({
    SortStudentsOrder? sortType,
    SortStudentsField? sortField,
    String? fio,
    int? minYear,
    int? maxYear,
    int? groupId,
    bool? confirmed,
    bool? deleted,
  }) {
    return FilterStudentParams(
      sortType: sortType ?? this.sortType,
      sortField: sortField ?? this.sortField,
      fio: fio ?? this.fio,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      groupId: groupId ?? this.groupId,
      confirmed: confirmed ?? this.confirmed,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, String> toQueryParams() {
    return {
      if (fio != null && fio!.isNotEmpty) 'fio': fio!,
      if (minYear != null) 'min_year': minYear.toString(),
      if (maxYear != null) 'max_year': maxYear.toString(),
      if (groupId != null) 'group_id': groupId.toString(),
      'confirmed': confirmed.toString(),
      'deleted': deleted.toString(),
      'sort_type': sortType.value,
      'sort_field': sortField.value,
    };
  }
}


